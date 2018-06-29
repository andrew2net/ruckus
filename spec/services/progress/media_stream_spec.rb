require 'rails_helper'

describe Progress::MediaStream do
  subject { described_class.new(profile) }

  let(:profile) { create(:candidate_profile) }
  let(:medium_params) { { profile: profile, position: 1 } }

  after { expect(subject.total_items_count).to eq 5 }

  specify 'without media' do
    expect(subject).to_not be_completed
    expect(subject.completed_items_count).to eq 0
    expect(subject.completed_percent).to eq 0
  end

  describe 'with one medium' do
    let!(:medium1) { create(:medium, medium_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 4
    end
  end

  describe 'with 2 media' do
    let!(:medium1) { create(:medium, medium_params) }
    let!(:medium2) { create(:medium, medium_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 2
      expect(subject.completed_percent).to eq 8
    end
  end

  describe 'with 3 media' do
    let!(:medium1) { create(:medium, medium_params) }
    let!(:medium2) { create(:medium, medium_params) }
    let!(:medium3) { create(:medium, medium_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 3
      expect(subject.completed_percent).to eq 12
    end
  end

  describe 'with 4 media' do
    let!(:medium1) { create(:medium, medium_params) }
    let!(:medium2) { create(:medium, medium_params) }
    let!(:medium3) { create(:medium, medium_params) }
    let!(:medium4) { create(:medium, medium_params) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 4
      expect(subject.completed_percent).to eq 16
    end
  end

  describe 'with 5 media' do
    let!(:medium1) { create(:medium, medium_params) }
    let!(:medium2) { create(:medium, medium_params) }
    let!(:medium3) { create(:medium, medium_params) }
    let!(:medium4) { create(:medium, medium_params) }
    let!(:medium5) { create(:medium, medium_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 5
      expect(subject.completed_percent).to eq 20
    end
  end

  describe 'with 6 media' do
    let!(:medium1) { create(:medium, medium_params) }
    let!(:medium2) { create(:medium, medium_params) }
    let!(:medium3) { create(:medium, medium_params) }
    let!(:medium4) { create(:medium, medium_params) }
    let!(:medium5) { create(:medium, medium_params) }
    let!(:medium6) { create(:medium, medium_params) }

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 5
      expect(subject.completed_percent).to eq 20
    end
  end
end
