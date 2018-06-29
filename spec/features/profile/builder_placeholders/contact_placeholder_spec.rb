require 'rails_helper'

describe 'Contact Info Placeholder' do
  let!(:account) { create :account }

  before { login_as(account, scope: :account) }

  describe 'showing photo' do
    let!(:profile) { create :candidate_profile, account: account, address_1: 'great street' }

    specify do
      visit profile_builder_path

      expect(page).to have_text 'great street'
      expect(page).to have_no_css '.text-placeholder', text: 'Contact'
    end
  end

  describe 'show placeholder' do
    let!(:profile) do
      create :candidate_profile, account: account,
                                 address_1: nil,
                                 address_2: nil,
                                 contact_city: nil,
                                 contact_state: nil,
                                 contact_zip: nil,
                                 phone: nil
    end

    specify do
      visit profile_builder_path

      expect(page).to have_css '.text-placeholder', text: 'Contact'
    end
  end
end
