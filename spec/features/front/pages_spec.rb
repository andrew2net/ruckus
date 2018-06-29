require 'rails_helper'

describe 'Pages' do
  describe 'Static Pages' do
    after :each do
      visit root_path
      within '#sm-screen-nav.sm-screen-nav' do
        click_on @button_name
      end

      expect(current_path).to eq @url

      visit root_path
      within '#footer.footer' do
        click_on @button_name
      end

      expect(current_path).to eq @url
    end

    specify 'FAQ' do
      @button_name = 'FAQ'
      @url = front_faq_path
    end

    specify 'Terms' do
      @button_name = 'Terms'
      @url = front_terms_path
    end

    specify 'Contact Us' do
      @button_name = 'Contact Us'
      @url = front_contact_us_path
    end
  end

  describe 'Support Message', :js do
    it 'should allow to send a message' do
      visit front_contact_us_path
      within '.contact-form-wrapper' do
        fill_in 'support_message_name',    with: 'Bob'
        fill_in 'support_message_email',   with: 'bob@gmail.com'
        fill_in 'support_message_subject', with: 'Test Subject'
        fill_in 'support_message_message', with: 'Test Message'
        click_on 'Send Message'
      end

      expect(page).to have_content 'Thank you'
    end

    it 'should not send blank message' do
      visit front_contact_us_path
      within '.contact-form-wrapper' do
        click_on 'Send Message'
      end

      expect(page).not_to have_content 'Thank you'
    end
  end
end
