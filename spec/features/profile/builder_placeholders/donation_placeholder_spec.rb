require 'rails_helper'

describe 'Donation Placeholder' do
  let(:profile) { create(:candidate_profile, donations_on: true) }
  let!(:account) { create :account, profile: profile }

  before { login_as(account, scope: :account) }

  context 'no DE account' do
    it 'redirects to New DE account page' do
      visit profile_builder_path
      hide_welcome_screen
      click_link '$'
      expect(current_path).to eq new_profile_de_account_path
    end
  end

  context 'DE account set up & inactive' do
    let!(:de_account) do
      create :de_account, profile:           profile,
                          account_full_name: 'Will Ferrell',
                          is_active_on_de:   false
    end

    it 'opens donation settings modal' do
      visit profile_builder_path
      hide_welcome_screen
      click_link '$'

      within '.ruckus-modal' do
        expect(page).to have_content 'To update your bank account or other information'
        expect(page).to have_content 'Will Ferrell'
        expect(page).to have_content 'awaiting approval'
      end
    end
  end

  context 'DE account set up & inactive' do
    let!(:de_account) do
      create :de_account, profile: profile,
                                       account_full_name: 'Will Ferrell',
                                       is_active_on_de: true
    end

    it 'allows to toggle donations' do
      visit profile_builder_path
      hide_welcome_screen
      click_link '$'

      within '.ruckus-modal' do
        expect(page).to have_content 'To update your bank account or other information'
        expect(page).to have_content 'Will Ferrell'
      end

      find('.ruckus-modal .switch-builder').click
      expect(page).not_to have_css '.ruckus-modal .switch-builder.active'
    end
  end
end
