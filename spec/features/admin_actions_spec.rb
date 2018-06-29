require 'rails_helper'

describe 'Admin Actions: ' do
  it 'sign in' do
    admin = create(:admin)

    login_as_admin admin

    expect(page).to have_content 'Signed in successfully.'
  end

  it 'sign out' do
    admin = create(:admin)
    login_as(admin, scope: :admin)

    visit '/admin'
    click_link 'Logout'

    expect(page).to have_content 'Signed out successfully.'
  end

  it 'bad sign in' do
    admin = build(:admin)

    login_as_admin admin

    expect(page).to have_content 'Invalid email or password'
  end
end
