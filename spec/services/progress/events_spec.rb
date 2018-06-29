require 'rails_helper'

describe Progress::Events do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile) }
  let(:event_params) { { profile: profile } }

  after { expect(subject.total_items_count).to eq 2 }

  specify 'without events' do
    expect(subject).to_not be_completed
    expect(subject.completed_items_count).to eq 0
    expect(subject.completed_percent).to eq 0
  end

  describe 'with 1 event' do
    let!(:event1) { create(:event, event_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 5
    end
  end

  describe 'with 2 events' do
    let!(:event1) { create(:event, event_params) }
    let!(:event2) { create(:event, event_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 2
      expect(subject.completed_percent).to eq 10
    end
  end

  describe 'with 3 events' do
    let!(:event1) { create(:event, event_params) }
    let!(:event2) { create(:event, event_params) }
    let!(:event3) { create(:event, event_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 2
      expect(subject.completed_percent).to eq 10
    end
  end
end
