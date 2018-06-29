require 'rails_helper'

describe Progress::CampaignUpdate do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile) }

  after { expect(subject.total_items_count).to eq 1 }

  specify 'without social posts' do
    expect(subject).to_not be_completed
    expect(subject.completed_items_count).to eq 0
    expect(subject.completed_percent).to eq 0
  end

  describe 'with social posts' do
    let!(:social_post) { create(:social_post, profile: profile) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 5
    end
  end
end
