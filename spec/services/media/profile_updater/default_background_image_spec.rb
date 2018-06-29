require 'rails_helper'

describe Media::ProfileUpdater::DefaultBackgroundImage do
  subject { described_class.new(profile) }

  let(:profile) do
    create(:candidate_profile, background_image_cropping_width:    nil,
                               background_image_cropping_height:   nil,
                               background_image_cropping_offset_x: nil,
                               background_image_cropping_offset_y: nil,
                               background_image_medium_id:         nil,
                               background_image:                   nil)
  end

  describe '#process' do
    let(:image) { File.open(Rails.root.join('spec', 'fixtures', 'backgrounds', 'Farm_2.jpg')) }
    let!(:default_medium) { create(:medium, image: image) }
    let!(:medium) { create(:medium, profile: profile) }

    specify do
      expect { subject.process }.to_not change(Medium, :count)

      profile.reload.tap do |profile|
        expect(profile.background_image_medium_id).to         eq default_medium.id
        expect(profile.background_image.url).to               end_with 'Farm_2.jpg'
        expect(profile.background_image_cropping_width).to    be_nil
        expect(profile.background_image_cropping_height).to   be_nil
        expect(profile.background_image_cropping_offset_x).to be_nil
        expect(profile.background_image_cropping_offset_y).to be_nil
      end
    end
  end
end
