require 'rails_helper'

describe 'Contact Us' do
  let!(:content) { create(:page, name: 'contact', data: 'contact_us_data').data }

  specify 'send a message', :js do
    visit root_path
    click_on 'Contact Us'
    expect(page).to have_content content

    fill_in 'support_message_name', with: 'Carl Johnson'
    fill_in 'support_message_email', with: 'cj@example.com'
    fill_in 'support_message_subject', with: 'Support Message Subject'
    fill_in 'support_message_message', with: 'Support Message Message'

    click_on 'Send Message'
    expect(page).to have_content 'Thank You!'
    expect(page).to have_content content
  end
end
