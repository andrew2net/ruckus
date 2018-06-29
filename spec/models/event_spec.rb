require 'rails_helper'

describe Event, cassette_name: :geocode_event_location do
  it 'should have associations' do
    expect(subject).to belong_to :profile
    expect(subject).to have_many(:scores)
    subject.scores.build
    expect(subject.scores.first.scorable_type).to eq 'Event'
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:title) }
    it { expect_to_validate_url_format(:link_url) }
    it { expect(subject).to validate_presence_of(:city) }
    it { expect(subject).to validate_presence_of(:state) }
    it { expect(subject).to validate_presence_of(:time_zone) }
    it { expect(subject).to validate_inclusion_of(:state).in_array(US_STATES_ABBREVIATIONS) }
    it { expect(subject).to validate_inclusion_of(:time_zone).in_array(TIME_ZONES.keys) }
    it { expect_to_validate_zip_format(:zip) }

    describe 'time correctness validation' do
      let(:event) do
        build :event, start_time_time: 'some text',
                      start_time_date: 'some text',
                      end_time_date: 'some text',
                      end_time_time: 'some text'
      end

      let(:event2) { build :event, start_time_date: '', start_time_time: '', start_time: nil }

      specify 'catching parsing errors' do
        expect(event).to be_invalid
        expect(event.errors[:base]).to include 'Start time is invalid'
        expect(event.errors[:base]).to include 'End time is invalid'
      end

      specify 'start time blank error' do
        expect(event2).to be_invalid
        expect(event2.errors[:base]).to include 'Start time is required'
      end
    end

    describe 'validation of end date being later than start date' do
      let!(:event1) { build :event, start_time: 1.hour.from_now, end_time: 3.hours.ago }
      let!(:event2) { build :event, start_time: 1.hour.from_now, end_time: 5.hours.from_now }
      let!(:event3) { build :event, start_time: 1.hour.from_now, end_time: nil }
      let!(:event4) { build :event, start_time: nil, end_time: nil }

      it 'should add error if start date is after the end date' do
        expect(event1).to be_invalid
        expect(event1.errors[:base]).to include 'Start time should precede the end time'
      end

      it 'should not add errors in other cases' do
        expect(event2).to be_valid
        expect(event3).to be_valid
      end

      it 'should handle situation when start_time is not set' do
        expect(event4).to be_invalid
        # make sure ArgumentError is not raised
      end
    end

    describe '#start_time_is_in_future', :unstub_event_time_validation do
      context 'normal conditions' do
        let!(:bad_event) { build :event, start_time: 1.hour.ago }
        let!(:good_event) { build :event, start_time: 1.hour.from_now }

        specify do
          expect(good_event).to be_valid
          expect(bad_event).to be_invalid
          expect(bad_event.errors[:base]).to include 'Start time should be in future'
        end
      end

      context 'event for today with no time' do
        let!(:good_event) { build :event, start_time_date: I18n.l(Time.now) }

        specify { expect(good_event).to be_valid }
      end
    end
  end

  describe 'public methods' do
    describe 'start_time' do
      let(:event) { create :event, start_time_date: '02/12/2014', start_time_time: '10pm', time_zone: 'EST' }

      specify do
        expected_time = 0
        Time.use_zone(TIME_ZONES['EST']) do
          expected_time = Time.zone.parse '12/02/2014 10pm'
        end
        expect(event.start_time).to eq expected_time
      end
    end

    describe 'end_time' do
      let(:event) { create :event, end_time_date: '12/12/2030', end_time_time: '10pm', time_zone: 'EST' }

      specify do
        expected_time = 0
        Time.use_zone(TIME_ZONES['EST']) do
          expected_time = Time.zone.parse '12/12/2030 10pm'
        end
        expect(event.end_time).to eq expected_time
      end
    end
  end

  describe 'scopes' do
    specify '::upcoming' do
      good_event = create :event, title: 'Great Event', start_time: 2.weeks.from_now
      bad_event = create :event, title: 'Too Late', start_time: 2.weeks.ago

      expect(Event.upcoming).to eq [good_event]
    end

    specify '::archive' do
      good_event = create :event, title: 'Great Event', start_time: 2.weeks.ago
      bad_event = create :event, title: 'Too Late', start_time: 2.weeks.from_now

      expect(Event.archive).to eq [good_event]
    end

    specify '::by_month' do
      event1 = create(:event, start_time: Time.now)
      event2 = create(:event, start_time: Time.now - 2.years)
      event3 = create(:event, start_time: Time.now - 2.months)

      Event.by_month(event1.start_time.month).tap do |events|
        expect(events.count).to eq 2
        expect(events).to include event1, event2
      end

      expect(Event.by_month(event3.start_time.month)).to eq [event3]
    end

    specify '::by_year' do
      Timecop.freeze(Date.new(2015, 5, 11)) do
        event1 = create(:event, start_time: Time.now)
        event2 = create(:event, start_time: Time.now - 2.months)
        event3 = create(:event, start_time: Time.now - 2.years)

        Event.by_year(event1.start_time.year).tap do |events|
          expect(events.count).to eq 2
          expect(events).to include event1, event2
        end

        expect(Event.by_year(event3.start_time.year)).to eq [event3]
      end
    end

    specify '::same_month' do
      event1 = create(:event, start_time: Time.now)
      event2 = create(:event, start_time: Time.now)
      event3 = create(:event, start_time: Time.now - 1.month)

      Event.same_month(event1).tap do |events|
        expect(events.count).to eq 2
        expect(events).to include event1, event2
      end

      expect(Event.same_month(event3)).to eq [event3]
    end

    specify '::earliest_first' do
      event1 = create(:event, start_time: Time.now)
      event2 = create(:event, start_time: Time.now - 2.years)
      event3 = create(:event, start_time: Time.now - 2.months)

      expect(Event.earliest_first).to eq [event2, event3, event1]
    end
  end

  describe 'older/newer event' do
    let!(:profile) { create(:candidate_profile) }
    let!(:event1) { create(:event, profile: profile, start_time: Time.now) }
    let!(:event2) { create(:event, profile: profile, start_time: Time.now - 1.month) }
    let!(:event3) { create(:event, profile: profile, start_time: Time.now - 1.year) }
    let!(:event4) { create(:event, start_time: Time.now - 2.years) }

    specify '#newer_event' do
      expect(event1.newer_event).to eq nil
      expect(event2.newer_event).to eq event1
      expect(event3.newer_event).to eq event2
      expect(event4.newer_event).to eq nil
    end

    specify '#older_event' do
      expect(event1.older_event).to eq event2
      expect(event2.older_event).to eq event3
      expect(event3.older_event).to eq nil
      expect(event4.older_event).to eq nil
    end
  end

  specify '#city_and_state' do
    event = create :event, city: 'City', state: 'NY'
    expect(event.city_and_state).to eq 'City, NY'
  end

  describe '#address_and_city' do
    it 'should save ' do
      event = create :event, address: 'street', city: 'City'
      expect(event.address_and_city).to eq 'street, City'
    end

    it 'should not include blank string values' do
      event = create :event, address: '', city: 'City'
      expect(event.address_and_city).to eq 'City'
    end

    it 'should not include nil value' do
      event = create :event, address: nil, city: 'City'
      expect(event.address_and_city).to eq 'City'
    end
  end

  describe '#location' do
    specify 'all fields present' do
      event = create :event, address: 'Some street', city: 'Good City', state: 'NY'
      expect(event.location).to eq 'Some street, Good City, NY'
    end

    specify 'some fields are blank' do
      event = create :event, address: nil, city: 'Good City', state: 'NY'
      expect(event.location).to eq 'Good City, NY'
    end
  end

  specify 'geocoder' do
    event = create :event, address: 'Some street', city: 'Good City', state: 'NY'

    event.reload.tap do |event|
      expect(event.latitude).to be_present
      expect(event.longitude).to be_present
    end
  end

  describe 'observres' do
    let(:default_time) { I18n.l(5.minutes.from_now, format: :hours_and_minutes) }

    describe '#set_start_time' do
      let(:event1) { create :event, start_time_date: '02/12/2014', start_time_time: '10pm' }
      let(:event2) { create :event, start_time_date: '02/12/2014', start_time_time: '' }
      let(:event3) { create :event, start_time: Time.zone.parse('23/02/2014 12am') }

      specify do
        Time.use_zone(TIME_ZONES['EDT']) do
          expect(event1.start_time.to_time).to eq Time.zone.parse '12/02/2014 10pm'
          expect(event2.start_time.to_time).to eq Time.zone.parse "12/02/2014 #{default_time}"
          expect(event3.start_time.to_time).to eq Time.zone.parse '23/02/2014 12am'
        end
      end
    end

    describe '#set_end_time' do
      let(:attrs) { { start_time: 5.minutes.from_now, end_time_date: '02/12/2015' } }
      let(:event1) { create :event, attrs.merge(end_time_time: '10pm') }
      let(:event2) { create :event, attrs.merge(end_time_time: '') }

      before { Timecop.freeze(Time.new(2014, 12, 12)) }
      after { Timecop.return }

      specify do
        Time.use_zone(TIME_ZONES['EDT']) do
          expect(event1.end_time.to_time).to eq Time.zone.parse '12/02/2015 10pm'
          expect(event2.end_time.to_time).to eq Time.zone.parse "12/02/2015 #{default_time}"
        end
      end
    end

    describe '#set_show_start_time' do
      let!(:event1) { create :event, start_time_date: '12/02/2015', start_time_time: '10pm' }
      let!(:event2) { create :event, start_time_date: '12/02/2015', start_time_time: '' }

      specify do
        expect(event1.show_start_time).to be_truthy
        expect(event2.show_start_time).to be_falsey
      end
    end

    describe '#set_show_end_time' do
      let(:default_params) { { start_time: Time.new(2015, 1, 2), end_time_date: '12/02/2015' } }
      let!(:event1) { create :event, default_params.merge(end_time_time: '10pm') }
      let!(:event2) { create :event, default_params.merge(end_time_time: '') }

      specify do
        expect(event1.show_end_time).to be_truthy
        expect(event2.show_end_time).to be_falsey
      end
    end
  end
end
