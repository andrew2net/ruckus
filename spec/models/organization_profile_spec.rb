require 'rails_helper'

describe OrganizationProfile do
  it_behaves_like 'Profile'

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to ensure_length_of(:name).is_at_least(2).is_at_most(255) }
    it { expect_to_validate_format_field(:name) }
  end

  describe 'cropping' do
    let!(:medium) { create :medium, image: File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }
    let(:profile) { create :organization_profile, photo_medium_id: medium.id }

    before { LogoUploader.enable_processing = true }
    after  { LogoUploader.enable_processing = false }

    it 'should not crop' do
      expect_any_instance_of(LogoUploader).not_to receive :crop
      profile.touch
    end
  end
end
