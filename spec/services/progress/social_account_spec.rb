require 'rails_helper'

describe Progress::SocialAccount do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile) }

  after { expect(subject.total_items_count).to eq 1 }

  describe 'uncompleted' do
    after do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 0
      expect(subject.completed_percent).to eq 0
    end

    specify('without Social Account') {}

    context 'with incactive Social Account' do
      let!(:oauth_account) { create :oauth_account, aasm_state: 'inactive', profile: profile }
      specify {}
    end
  end

  describe 'complited' do
    context 'with active Social Account' do
      let!(:oauth_account) { create :oauth_account, aasm_state: 'active', profile: profile }

      specify do
        expect(subject).to be_completed
        expect(subject.completed_items_count).to eq 1
        expect(subject.completed_percent).to eq 5
      end
    end
  end
end
