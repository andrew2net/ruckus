require 'rails_helper'

describe PressReleaseImage do
  describe 'associations' do
    it { expect(subject).to belong_to :profile }

    describe 'press_release' do
      let!(:press_release) { create(:press_release) }
      let!(:image1) { create(:press_release_image, profile: press_release.profile) }
      let!(:image2) { create(:press_release_image, press_release_url: press_release.url) }
      let!(:image3) do
        create(:press_release_image, profile:         press_release.profile,
                                     press_release_url: press_release.url)
      end

      specify do
        expect(image1.press_release).to be_nil
        expect(image2.press_release).to be_nil
        expect(image3.press_release).to eq press_release
      end
    end
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:profile) }
    it { expect(subject).to validate_presence_of(:press_release_url) }
  end

  describe 'scopes' do
    describe '::active & ::inactive' do
      let!(:image1) { create(:press_release_image, active: true) }
      let!(:image2) { create(:press_release_image, active: false) }
      let!(:image3) { create(:press_release_image, active: nil) }

      specify do
        expect(PressReleaseImage.active).to eq [image1]
        expect(PressReleaseImage.inactive.sort).to eq [image2, image3].sort
      end
    end
  end
end
