require 'rails_helper'

describe 'Domains', :js do
  let(:profile) { create(:candidate_profile, :premium) }
  let(:account) { create :account, profile: profile }
  let(:domain)  { profile.domain }

  before { open_domains_path(account) }

  it 'should show my domains' do
    expect(page).not_to have_selector('domain-list.section-disabled')
    expect(page).to have_content("#{domain.name}")
    expect(page).to have_css("a.domain-link[href*='#{domain.name}']", count: 1)
  end

  it 'should have upgrade cancel button' do
    expect(page).to have_css('.cancel.pull-right')

    profile.credit_card_holder.destroy
    visit current_url

    expect(page).not_to have_css('.cancel.pull-right')
  end

  describe 'Edit domain' do
    before { click_on 'Rename' }

    specify 'success' do
      fill_in 'domain_name', with: 'new-name'
      click_on 'Update', visible: false

      expect(page).to have_content('new-name')
    end

    specify 'validation error' do
      fill_in 'domain_name', with: ''
      click_on 'Update'

      expect(page).to have_content("can't be blank")
    end
  end
end

describe 'premium vs free' do
  context 'free' do
    let(:profile) { create :candidate_profile, :free }
    let(:account) { create :account, profile: profile }
    before { open_domains_path(account) }

    specify { expect(page).to have_link 'Upgrade' }
  end

  context 'premium', :js do
    let(:profile) { create(:candidate_profile, :premium) }
    let(:account) { create :account, profile: profile }
    let!(:domain2) { create(:domain, profile: profile) }
    let!(:domain3) { create(:domain, profile: profile) }

    before { open_domains_path(account) }

    specify { expect(page).to have_content 'Your IP address is' }

    specify 'add' do
      click_on 'Add New Domain'
      fill_in 'domain_name', with: '*.'
      click_on 'Add'

      expect(page).to have_selector('.help-inline', text: 'invalid domain name')

      fill_in 'domain_name', with: 'someothersite1.com'
      click_on 'Add'

      expect(page).to have_css '.domain-url', text: 'someothersite1.com'
    end

    specify 'edit', :js do
      within "#domain-#{domain2.id}" do
        click_on 'Edit'
        expect(page).to have_selector('form.edit_domain', count: 1)
      end

      within "#domain-#{domain3.id}" do
        click_on 'Edit'
        expect(page).to have_selector('form.edit_domain', count: 1)
      end

      fill_in 'domain_name', with: 'differentname.com'
      click_on 'Update'
      expect(page).to have_no_content 'UPDATE'

      expect(page).to have_css '.domain-url', text: 'differentname.com'
      expect(page).not_to have_css '.domain-url', text: domain3.name
    end

    specify 'delete' do
      expect(page).to have_css '.domain-url', text: domain3.name

      within "#domain-#{domain3.id}" do
        click_on 'Delete'
      end

      expect(page).not_to have_css '.domain-url', text: domain3.name
    end
  end
end

def open_domains_path(account)
  login_as(account, scope: :account)
  visit profile_domains_path
  hide_welcome_screen
end
