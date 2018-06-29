require 'rails_helper'

describe 'Pages' do
  let!(:admin) { create :admin }
  before do
    create :page, name: 'faq'
    create :page, name: 'contact'
    create :page, name: 'terms'

    login_as_admin(admin)

    visit admin_root_path
    click_on 'Pages'
  end

  describe 'FAQ' do
    it 'should edit FAQ' do
      click_on 'Edit FAQ'

      fill_in 'Data', with: 'some FAQ with <b>tags</b>'
      click_on 'Save'

      visit front_faq_path
      expect(page.html).to include 'some FAQ with <b>tags</b>'
    end
  end

  describe 'Contact Us' do
    it 'should edit Contact Info' do
      click_on 'Edit Contact'

      fill_in 'Data', with: 'some Contact Info with <b>tags</b>'
      click_on 'Save'

      visit front_contact_us_path
      expect(page.html).to include 'some Contact Info with <b>tags</b>'
    end
  end

  describe 'Terms' do
    it 'should edit Terms' do
      click_on 'Edit Terms'

      fill_in 'Data', with: 'some Terms with <b>tags</b>'
      click_on 'Save'

      visit front_terms_path
      expect(page.html).to include 'some Terms with <b>tags</b>'
    end
  end
end
