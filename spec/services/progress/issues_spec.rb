require 'rails_helper'

describe Progress::Issues do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile) }
  let(:issue_category) { create(:issue_category, profile: profile) }
  let(:issue_params) { { profile: profile, issue_category: issue_category } }

  after { expect(subject.total_items_count).to eq 3 }

  specify 'without issues' do
    expect(subject).to_not be_completed
    expect(subject.completed_items_count).to eq 0
    expect(subject.completed_percent).to eq 0
  end

  describe 'with 1 issue' do
    let!(:issue1) { create(:issue, issue_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 5
    end
  end

  describe 'with 2 issues' do
    let!(:issue1) { create(:issue, issue_params) }
    let!(:issue2) { create(:issue, issue_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 2
      expect(subject.completed_percent).to eq 10
    end
  end

  describe 'with 3 issues' do
    let!(:issue1) { create(:issue, issue_params) }
    let!(:issue2) { create(:issue, issue_params) }
    let!(:issue3) { create(:issue, issue_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 3
      expect(subject.completed_percent).to eq 15
    end
  end

  describe 'with 4 issues' do
    let!(:issue1) { create(:issue, issue_params) }
    let!(:issue2) { create(:issue, issue_params) }
    let!(:issue3) { create(:issue, issue_params) }
    let!(:issue4) { create(:issue, issue_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 3
      expect(subject.completed_percent).to eq 15
    end
  end
end
