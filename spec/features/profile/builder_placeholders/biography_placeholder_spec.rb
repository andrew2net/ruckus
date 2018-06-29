require 'rails_helper'

describe 'Biography switch' do
  let!(:account) { create :account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable' do
    describe 'enable' do
      let!(:profile) { create :candidate_profile, account: account, biography: 'something' }

      it 'shows biography block' do
        visit profile_builder_path

        expect(page).to have_css '#about-tab-wrapper'
        expect(page).to have_content 'something'
      end
    end

    describe 'disable' do
      let!(:profile) { create :candidate_profile, account: account, biography: '' }

      it 'shows placeholder' do
        visit profile_builder_path

        expect(page).not_to have_css '#about-tab-wrapper'
        expect(page).to have_content 'Add Biography'
      end
    end
  end
end
