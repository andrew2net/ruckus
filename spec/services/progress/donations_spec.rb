require 'rails_helper'

describe Progress::Donations do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile, donations_on: donations_on) }

  after { expect(subject.total_items_count).to eq 1 }

  describe 'without DE account' do
    after do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 0
      expect(subject.completed_percent).to eq 0
    end

    describe 'with donations_on == false' do
      let(:donations_on) { false }
      specify {}
    end

    describe 'with donations_on == true' do
      let(:donations_on) { true }
      specify {}
    end
  end

  describe 'with DE account' do
    let!(:de_account) { create(:de_account, profile: profile) }

    describe 'with donations_on == false' do
      let(:donations_on) { false }

      specify do
        expect(subject).to_not be_completed
        expect(subject.completed_items_count).to eq 0
        expect(subject.completed_percent).to eq 0
      end
    end

    describe 'with donations_on == true' do
      let(:donations_on) { true }

      specify do
        expect(subject).to be_completed
        expect(subject.completed_items_count).to eq 1
        expect(subject.completed_percent).to eq 5
      end
    end
  end
end
