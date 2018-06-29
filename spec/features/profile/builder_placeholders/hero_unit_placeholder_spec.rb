require 'rails_helper'

describe 'Biography switch' do
  let(:profile)   { create(:candidate_profile) }
  let(:account)   { create :account, profile: profile }
  let(:hero_unit) { create :medium, profile: profile }
  let(:hero_unit_medium_id) { nil }

  before do
    profile.update hero_unit_medium_id: hero_unit_medium_id
    login_as(account, scope: :account)
    visit profile_builder_path
  end

  describe 'enable/disable' do
    describe 'enable' do
      let(:hero_unit_medium_id) { hero_unit.id }

      it 'shows biography block' do
        expect(page).to have_css '#about-video'
      end
    end

    describe 'disable' do
      it 'shows placeholder' do
        expect(page).to have_no_css '#about-video'
        expect(page).to have_content 'Add Featured Image'
      end
    end
  end
end
