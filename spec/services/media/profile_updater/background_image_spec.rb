require 'rails_helper'

describe Media::ProfileUpdater::BackgroundImage do
  subject { described_class.new(profile, params) }

  let(:profile) do
    create(:candidate_profile, background_image_cropping_width:    nil,
                               background_image_cropping_height:   nil,
                               background_image_cropping_offset_x: nil,
                               background_image_cropping_offset_y: nil,
                               background_image_medium_id:         nil,
                               background_image:                   nil)
  end

  let(:params) { { profile: data } }

  describe '#process' do
    let(:image) { File.open(Rails.root.join('spec', 'fixtures', 'background.jpg')) }
    let(:crop_data) do
      {
        background_image_cropping_width:    1,
        background_image_cropping_height:   2,
        background_image_cropping_offset_x: 3,
        background_image_cropping_offset_y: 4
      }
    end

    after do
      expect(profile.background_image.url).to               end_with 'background.jpg'
      expect(profile.background_image_cropping_width).to    eq 1
      expect(profile.background_image_cropping_height).to   eq 2
      expect(profile.background_image_cropping_offset_x).to eq 3
      expect(profile.background_image_cropping_offset_y).to eq 4
    end

    context 'with existing medium' do
      let!(:medium) { create(:medium, profile: profile, image: image) }
      let(:data) { crop_data.merge(background_image_medium_id: medium.id) }

      specify do
        expect { subject.process }.to_not change(Medium, :count)
        expect(profile.reload.background_image_medium_id).to eq medium.id
      end
    end

    context 'with new medium' do
      let(:data) { crop_data.merge(background_image_medium: { image: image }) }

      specify do
        expect { subject.process }.to change { profile.media.count }.by(1)
        expect(profile.reload.background_image_medium_id).to_not be_nil
      end
    end
  end
end
