require 'rails_helper'

describe Media::ProfileUpdater::Photo do
  subject { described_class.new(profile, params) }

  let(:profile) do
    create(:candidate_profile, photo_cropping_width:    nil,
                               photo_cropping_offset_x: nil,
                               photo_cropping_offset_y: nil,
                               photo_medium_id:         nil,
                               photo:                   nil)
  end

  let(:params) { { profile: data } }

  describe '#process' do
    let(:image) { File.open(Rails.root.join('spec', 'fixtures', 'photo.jpg')) }
    let(:crop_data) do
      {
        photo_cropping_width:    1,
        photo_cropping_offset_x: 2,
        photo_cropping_offset_y: 3
      }
    end

    after do
      expect(profile.photo.url).to               end_with 'photo.jpg'
      expect(profile.photo_cropping_width).to    eq 1
      expect(profile.photo_cropping_offset_x).to eq 2
      expect(profile.photo_cropping_offset_y).to eq 3
    end

    context 'with existing medium' do
      let!(:medium) { create(:medium, profile: profile, image: image) }
      let(:data) { crop_data.merge(photo_medium_id: medium.id) }

      specify do
        expect { subject.process }.to_not change(Medium, :count)
        expect(profile.reload.photo_medium_id).to eq medium.id
      end
    end

    context 'with new medium' do
      let(:data) { crop_data.merge(photo_medium: { image: image }) }

      specify do
        expect { subject.process }.to change { profile.media.count }.by(1)
        expect(profile.reload.photo_medium_id).to_not be_nil
      end
    end
  end
end
