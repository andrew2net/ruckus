require 'rails_helper'

describe Progress::PressReleases do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile) }
  let(:press_params) { { profile: profile } }

  after { expect(subject.total_items_count).to eq 2 }

  specify 'without press' do
    expect(subject).to_not be_completed
    expect(subject.completed_items_count).to eq 0
    expect(subject.completed_percent).to eq 0
  end

  describe 'with 1 press' do
    let!(:press1) { create(:press_release, press_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 5
    end
  end

  describe 'with 2 press' do
    let!(:press1) { create(:press_release, press_params) }
    let!(:press2) { create(:press_release, press_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 2
      expect(subject.completed_percent).to eq 10
    end
  end

  describe 'with 3 press' do
    let!(:press1) { create(:press_release, press_params) }
    let!(:press2) { create(:press_release, press_params) }
    let!(:press3) { create(:press_release, press_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 2
      expect(subject.completed_percent).to eq 10
    end
  end
end
