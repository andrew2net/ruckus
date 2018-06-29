require 'rails_helper'

describe 'Event: ' do
  let(:profile) { create :candidate_profile, events_on: true }
  let(:account) { create :account, profile: profile }

  describe 'Event popup markup' do
    let!(:event1)   do
      create :event, profile: profile,
                     start_time: Time.parse('13/02/2016 10:23AM'),
                     address: '2936 Mercedes Summit',
                     description: "Some\nText",
                     city: 'Thompsonmouth',
                     title: 'Event 1 title',
                     end_time: Time.parse('13/02/2016 4:35PM')
    end

    let!(:event2)   do
      create :event, start_time: Time.parse('13/05/2016 10:23AM'),
                     end_time: nil,
                     description: "Some\nText",
                     profile: profile
    end

    it 'should show event' do
      allow_any_instance_of(Event).to receive(:latitude).and_return '1234'
      allow_any_instance_of(Event).to receive(:longitude).and_return '4321'

      visit front_profile_events_path(profile, event_id: event1.id)

      expect(page).to have_css '.title h3', text: 'Event 1 title'
      expect(page).to have_css '.title span.location', text: '2936 Mercedes Summit'
      expect(page).to have_css 'li', text: 'Date: February, 13, 2016'
      expect(page).to have_css 'li', text: "Place: 2936 Mercedes Summit, Thompsonmouth, #{event1.state}"
      expect(page.html).to include "Some\n<br />Text"
    end

    describe 'displaying time' do
      let(:event3) do
        create :event, profile: profile,
                       start_time_date: '02/13/2016',
                       start_time_time: '10:23AM',
                       end_time_date: '02/13/2016',
                       end_time_time: '1:23PM'
      end
      let(:event4) do
        create :event, profile: profile,
                       start_time_date: '02/13/2016',
                       start_time_time: '',
                       end_time_date: '',
                       end_time_time: ''
      end
      let(:event5) do
        create :event, profile: profile,
                       start_time_date: '02/13/2016',
                       start_time_time: '10:23AM',
                       end_time_date: '02/15/2016',
                       end_time_time: ''
      end
      let(:event6) do
        create :event, profile: profile,
                       start_time_date: '02/13/2016',
                       start_time_time: '10:23AM',
                       end_time_date: '',
                       end_time_time: ''
      end

      it 'should show Start Time - End Time when both are present' do
        visit front_profile_events_path(profile, event_id: event3.id)

        expect(page).to have_css 'li', text: 'Time: 10:23am-1:23pm'
      end

      it 'should show N/A when there is no start time' do
        visit front_profile_events_path(profile, event_id: event4.id)

        expect(page).to have_css 'li', text: 'Time: N/A'
      end

      it 'should show Start Time without a dash when End Time is not present' do
        [event5, event6].each do |event|
          visit front_profile_events_path(profile, event_id: event.id)

          expect(page).to have_css 'li', text: 'Time: 10:23am'
          expect(page).to have_no_css 'li', text: 'Time: 10:23am-'
        end
      end
    end
  end

  describe 'archive for expired events' do
    let!(:event1)   { create :event, profile: profile, title: 'Bad Title', start_time: Date.tomorrow + 9.hours }
    let!(:event2)   { create :event, profile: profile, title: 'Good Title', start_time: Time.now - 1.year }

    before { visit with_subdomain(profile.domain.name) }

    it 'should show archive', :old_feature do
      click_on 'View Archive'
      expect(page).to have_css 'h4', text: 'Archive'
      expect(page).to have_content 'Good Title'
      expect(page).to have_no_content 'Bad Title'
    end
  end

  describe 'Popup navigation', :js do
    before { Timecop.travel(Date.new(2016, 04, 1)) }
    after  { Timecop.return }

    let(:profile)    { create :candidate_profile, events_on: true, premium_by_default: true }
    let!(:account)   { create :account, profile: profile }
    let!(:ownership) { create :ownership, profile: profile, account: account }
    let!(:event1)   do
      create :event, profile: profile,
                     start_time: Time.parse('15 April 2016'),
                     address: '1058 Olson Cape',
                     description: 'Quam ea voluptatem ullam explicabo sit.',
                     title: 'Event 1 title',
                     link_text: 'Link Text',
                     link_url: 'http://url.com',
                     state: 'VA'
    end
    let!(:event2)   do
      create :event, profile: profile,
                     start_time: Time.parse('15 March 2016'),
                     address: '1058 Olson Cape',
                     description: 'Quam ea voluptatem ullam explicabo sit.',
                     title: 'Event 2 title'
    end
    let!(:event3)   do
      create :event, profile: profile,
                     start_time: Time.parse('15 May 2016'),
                     address: '37745 Ray Prairie',
                     description: 'Voluptatem amet praesentium id harum aut doloribus cum.',
                     title: 'Event 3 title'
    end

    before { visit with_subdomain(profile.domain.name) }

    specify 'Events for this month' do
      find("#event-preview-#{event1.id} a").click
      expect(page).to have_css '.events-modal'

      within '.events-modal' do
        expect(page).to have_content 'Event 1 title'
        expect(page).to have_link 'Link Text', href: 'http://url.com'
        expect(page).to have_content 'Quam ea voluptatem ullam explicabo sit.'
        expect(page).to have_css 'h4', text: 'April'
        expect(page).to have_css 'span.year', text: '2016'
      end
    end

    xspecify 'Previous Month button' do
      find("#event-preview-#{event1.id} a").click
      expect(page).to have_css '.ruckus-modal'

      within '.events-modal' do
        find('.fa-chevron-left').click
        expect(page).to have_no_content 'Event 1 title'
        expect(page).to have_content 'Event 2 title'
        expect(page).to have_content 'Quam ea voluptatem ullam explicabo sit.'
        expect(page).to have_css 'h4', text: 'March'
        expect(page).to have_css 'span.year', text: '2016'
      end
    end

    xspecify 'Next Month button' do
      find("#event-preview-#{event1.id} a").click
      expect(page).to have_css '.events-modal'

      within '.events-modal' do
        find('.fa-chevron-right').click
        expect(page).to have_no_content 'Event 1 title'
        expect(page).to have_content 'Event 3 title'
        expect(page).to have_content 'Voluptatem amet praesentium id harum aut doloribus cum.'
        expect(page).to have_css 'h4', text: 'May'
        expect(page).to have_css 'span.year', text: '2016'
      end
    end
  end

  describe 'displaying OG tags' do
    let!(:event)   { create :event, profile: profile }

    specify do
      visit front_profile_event_path(profile, event)

      expect(page).to have_selector :xpath, '//head/meta[@property="fb:app_id"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:site_name"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:type"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:title"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:description"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:url"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:image"]', visible: false
    end
  end
end
