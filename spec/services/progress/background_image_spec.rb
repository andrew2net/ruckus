require 'rails_helper'

describe Progress::BackgroundImage do
  subject { described_class.new(profile) }

  after { expect(subject.total_items_count).to eq 1 }

  describe 'without background' do
    let(:profile) { create(:candidate_profile) }

    specify do
      expect(subject).to_not be_completed
      expect(subject.completed_items_count).to eq 0
      expect(subject.completed_percent).to eq 0
    end
  end

  describe 'with background' do
    let(:medium) { create(:medium) }
    let(:profile) do
      create(:candidate_profile, media:                   [medium],
                                 background_image_medium: medium,
                                 background_image:        medium.image)
    end

    specify do
      expect(subject).to be_completed
      expect(subject.completed_items_count).to eq 1
      expect(subject.completed_percent).to eq 5
    end
  end
end
