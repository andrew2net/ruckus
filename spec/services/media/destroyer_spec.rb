require 'rails_helper'

describe Media::Destroyer do
  subject { described_class.new(medium_to_destroy) }

  describe '#process' do
    let!(:medium)                  { create(:medium, profile: profile) }
    let!(:photo_medium)            { create(:medium, profile: profile) }
    let!(:background_image_medium) { create(:medium, profile: profile) }
    let!(:hero_unit_medium)        { create(:medium, profile: profile) }
    let!(:image) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }
    let!(:profile) { create(:candidate_profile) }

    let(:profile_attrs) do
      {
        photo_medium_id:                    photo_medium.id,
        photo:                              photo_medium.image,
        photo_cropping_width:               10,
        photo_cropping_offset_x:            11,
        photo_cropping_offset_y:            12,
        background_image_medium_id:         background_image_medium.id,
        background_image:                   background_image_medium.image,
        background_image_cropping_width:    20,
        background_image_cropping_height:   21,
        background_image_cropping_offset_y: 22,
        background_image_cropping_offset_x: 23,
        hero_unit:                          hero_unit_medium.image,
        hero_unit_medium_id:                hero_unit_medium.id
      }
    end

    before do
      profile.update(profile_attrs)
      expect { expect(subject.process).to be_truthy }.to change(Medium, :count).by(-1)
    end

    describe 'simple medium' do
      let(:medium_to_destroy) { medium }

      specify do
        Profile.find(profile.id).tap do |profile|
          expect(profile.photo_medium_id).to                    eq photo_medium.id
          expect(profile.photo.url).to_not                      end_with('default.png')
          expect(profile.photo_cropping_width).to               eq 10
          expect(profile.photo_cropping_offset_x).to            eq 11
          expect(profile.photo_cropping_offset_y).to            eq 12
          expect(profile.background_image_medium_id).to         eq background_image_medium.id
          expect(profile.background_image.url).to_not           end_with('default.png')
          expect(profile.background_image_cropping_width).to    eq 20
          expect(profile.background_image_cropping_height).to   eq 21
          expect(profile.background_image_cropping_offset_y).to eq 22
          expect(profile.background_image_cropping_offset_x).to eq 23
          expect(profile.hero_unit.url).to_not                  end_with('default.png')
          expect(profile.hero_unit_medium_id).to                eq hero_unit_medium.id
        end
      end
    end

    describe 'photo' do
      let(:medium_to_destroy) { photo_medium }

      specify do
        Profile.find(profile.id).tap do |profile|
          expect(profile.photo_medium_id).to                    be_nil
          expect(profile.photo.url).to                          end_with('default.png')
          expect(profile.photo_cropping_width).to               be_nil
          expect(profile.photo_cropping_offset_x).to            be_nil
          expect(profile.photo_cropping_offset_y).to            be_nil
          expect(profile.background_image_medium_id).to         eq background_image_medium.id
          expect(profile.background_image.url).to_not           end_with('default.png')
          expect(profile.background_image_cropping_width).to    eq 20
          expect(profile.background_image_cropping_height).to   eq 21
          expect(profile.background_image_cropping_offset_y).to eq 22
          expect(profile.background_image_cropping_offset_x).to eq 23
          expect(profile.hero_unit.url).to_not                  end_with('default.png')
          expect(profile.hero_unit_medium_id).to                eq hero_unit_medium.id
        end
      end
    end

    describe 'background image' do
      let(:medium_to_destroy) { background_image_medium }

      specify do
        Profile.find(profile.id).tap do |profile|
          expect(profile.photo_medium_id).to                    eq photo_medium.id
          expect(profile.photo.url).to_not                      end_with('default.png')
          expect(profile.photo_cropping_width).to               eq 10
          expect(profile.photo_cropping_offset_x).to            eq 11
          expect(profile.photo_cropping_offset_y).to            eq 12
          expect(profile.background_image_medium_id).to         be_nil
          expect(profile.background_image.url).to               end_with('default.png')
          expect(profile.background_image_cropping_width).to    be_nil
          expect(profile.background_image_cropping_height).to   be_nil
          expect(profile.background_image_cropping_offset_y).to be_nil
          expect(profile.background_image_cropping_offset_x).to be_nil
          expect(profile.hero_unit.url).to_not                  end_with('default.png')
          expect(profile.hero_unit_medium_id).to                eq hero_unit_medium.id
        end
      end
    end

    describe 'hero unit' do
      let(:medium_to_destroy) { hero_unit_medium }

      specify do
        Profile.find(profile.id).tap do |profile|
          expect(profile.photo_medium_id).to                    eq photo_medium.id
          expect(profile.photo.url).to_not                      end_with('default.png')
          expect(profile.photo_cropping_width).to               eq 10
          expect(profile.photo_cropping_offset_x).to            eq 11
          expect(profile.photo_cropping_offset_y).to            eq 12
          expect(profile.background_image_medium_id).to         eq background_image_medium.id
          expect(profile.background_image.url).to_not           end_with('default.png')
          expect(profile.background_image_cropping_width).to    eq 20
          expect(profile.background_image_cropping_height).to   eq 21
          expect(profile.background_image_cropping_offset_y).to eq 22
          expect(profile.background_image_cropping_offset_x).to eq 23
          expect(profile.hero_unit.url).to                      end_with('default.png')
          expect(profile.hero_unit_medium_id).to                be_nil
        end
      end
    end
  end
end
