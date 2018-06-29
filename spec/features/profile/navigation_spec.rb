require 'rails_helper'

describe "Navigatoin" do
  let(:name) { 'John Smith' }
  let!(:account) { create :account, email: 'test123@example.com' }
  let!(:profile) { create :candidate_profile, name: name, account: account }

  before { login_as(account, scope: :account) }

  describe 'check content' do
    let(:name) { 'bob' }

    before do
      visit profile_builder_path
    end

    it 'should have link' do
      expect(page).to have_link 'View Live Site', href: 'http://bob.example.com/'
      expect(page).to have_css '.spinner'

      within '.user-dropdown' do
        expect(page).to have_content 'My Account'
        expect(page).to have_content 'test123@example.com'
      end
    end
  end

  describe 'check active links' do
    let(:links) { %w(Dashboard Builder Settings) }

    def check_active_links(active_text)
      within '.admin-nav' do
        links.each { |link| expect(page).to have_link link  }
        expect(find('a.active').text).to eq active_text
      end
    end

    specify do
      visit profile_root_path
      check_active_links('Builder')

      links.each do |link|
        click_link link
        check_active_links(link)
      end
    end
  end
end
