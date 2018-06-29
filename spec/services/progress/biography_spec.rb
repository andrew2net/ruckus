require 'rails_helper'

describe Progress::Biography do
  subject { described_class.new(profile) }

  after { expect(subject.total_items_count).to eq 1 }

  describe 'without biography' do
    let(:profile) { create(:candidate_profile, biography: ' ') }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 0
      expect(subject.completed_percent).to eq 0
    end
  end

  describe 'with biography' do
    let(:profile) { create(:candidate_profile, biography: 'I am Batman') }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 5
    end
  end
end
