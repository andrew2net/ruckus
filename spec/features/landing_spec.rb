require 'rails_helper'

describe 'Landing page' do
  specify 'unauthenticated' do
    visit root_path
    expect(page).to have_link('View a Sample Site »')

    within '.hero' do
      expect(page).to have_link('Start Building Now', href: new_account_registration_path)
    end

    within '.process' do
      expect(page).to have_link('Start Building Now', href: new_account_registration_path)
    end

    within '.footer' do
      expect(page).to have_link('Accounts Start Here', href: new_account_registration_path)
    end
  end
end
