require 'rails_helper'

describe Medium  do
  describe 'concerns' do
    it_behaves_like 'sortable'
  end

  describe 'associations' do
    it { expect(subject).to belong_to :profile }
  end

  describe 'validations' do
    # todo: (after crop) Display validation errors on Media Upload page (+ refactor forms)
    it { expect_to_validate_url_format(:video_url, :youtube_or_vimeo_video_format) }

    it 'should validate page existence and format', :unstub_url_existence do
      expect_to_validate_page_existence(:video_url, :video)
    end

    describe '#presence_of_image_or_video_url' do
      specify do
        expect(build :medium, image: File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')),
                              video_url: nil).to be_valid
      end
      it { expect(build :medium, image: nil, video_url: VIDEOS[:vimeo][:url]).to be_valid }
      it { expect(build :medium, image: nil, video_url: nil).not_to be_valid }
    end
  end

  describe '::only_images', cassette_name: :vimeo_video do
    let!(:image) do
      create :medium, video_url: nil,
                      image: File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg'))
    end
    let!(:video) { create :medium, image: nil, video_url: VIDEOS[:vimeo][:url] }

    it 'lists only images' do
      expect(Medium.only_images).to eq [image]
    end
  end

  describe '::only_videos', cassette_name: :vimeo_video do
    let!(:image) do
      create :medium, video_url: nil,
                      image: File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg'))
    end
    let!(:video) { create :medium, image: nil, video_url: VIDEOS[:vimeo][:url] }

    it 'lists only videos' do
      expect(Medium.only_videos).to eq [video]
    end
  end

  describe '::ruckus_global' do
    let!(:profile) { create(:candidate_profile) }
    let!(:bad_medium) { create(:medium, profile: profile) }
    let!(:good_medium) { create(:medium, profile: nil) }

    it 'should list media without account' do
      expect(Medium.ruckus_global).to eq [good_medium]
    end
  end

  describe '::with_profile' do
    let!(:profile) { create(:candidate_profile) }
    let!(:bad_medium) { create(:medium, profile: nil) }
    let!(:good_medium) { create(:medium, profile: profile) }

    it 'should list media without account' do
      expect(Medium.with_profile).to eq [good_medium]
    end
  end

  describe '#ruckus?' do
    let!(:medium1) { build(:medium, profile_id: nil) }
    let!(:medium2) { build(:medium, profile_id: 1) }

    specify do
      expect(medium1).to be_ruckus
      expect(medium2).not_to be_ruckus
    end
  end

  describe '#active?' do
    let!(:medium1) { build :medium, position: nil }
    let!(:medium2) { build :medium, position: 1 }

    specify do
      expect(medium1).not_to be_active
      expect(medium2).to be_active
    end
  end

  describe '#video?' do
    let!(:medium1) { build :medium, video_url: VIDEOS[:vimeo][:url] }
    let!(:medium2) { build :medium, video_url: nil }

    specify do
      expect(medium1).to be_video
      expect(medium2).not_to be_video
    end
  end

  describe '#width' do
    let!(:medium) { create :medium }

    specify { expect(medium.width).to eq 929 }
  end

  describe '#height' do
    let!(:medium) { create :medium }

    specify { expect(medium.height).to eq 783 }
  end
end
