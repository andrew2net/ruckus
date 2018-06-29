require 'rails_helper'

describe Media::ProfileUpdater::HeroUnit do
  subject { described_class.new(profile, params) }

  let(:profile) { create(:candidate_profile, hero_unit_medium_id: nil, hero_unit: nil) }
  let(:params) { { profile: data } }

  describe '#process' do
    let(:image) { File.open(Rails.root.join('spec', 'fixtures', 'background.jpg')) }
    let!(:medium) { create(:medium, profile: profile, image: image) }

    after do
      profile.reload.tap do |profile|
        expect(profile.hero_unit_medium_id).to eq medium.id
        expect(profile.hero_unit.url).to end_with 'background.jpg'
      end
    end

    context 'with existing medium' do
      let(:data) { { hero_unit_medium_id: medium.id } }

      specify do
        expect { subject.process }.to_not change(Medium, :count)
      end
    end

    context 'with new medium' do
      let(:creator_class) { Media::Creator }
      let(:data) { { hero_unit_medium: { video_url: 'video_url', image: 'image' } } }

      before { allow_any_instance_of(creator_class).to receive(:create).and_return(medium) }

      specify do
        expect(creator_class).to receive(:new).with(profile, video_url: 'video_url', images: ['image'])
                                              .and_call_original
        subject.process
      end
    end
  end
end
