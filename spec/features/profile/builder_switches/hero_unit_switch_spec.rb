require 'rails_helper'

describe 'Featured unit switch' do
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable', :js do
    let(:medium) { create(:medium) }

    describe 'enable' do
      let!(:profile) do
        create :candidate_profile, hero_unit_medium_id: medium.id,
                                   hero_unit:           medium.image,
                                   hero_unit_on:        false,
                                   premium_by_default:  true
      end

      it { enables_the_block('#about-video-switch', '#about-video') }
    end

    describe 'disable' do
      let!(:profile) do
        create :candidate_profile, hero_unit_medium_id: medium.id,
                                   hero_unit:           medium.image,
                                   hero_unit_on:        true
      end
      it { disables_the_block('#about-video-switch', '#about-video') }
    end
  end

  describe 'hide' do
    let!(:profile) { create :candidate_profile }

    specify do
      visit profile_builder_path
      expect(page).to have_no_css '#about-video-switch'
    end
  end
end
