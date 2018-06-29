require 'rails_helper'

describe 'Domains' do
  let!(:admin)     { create :admin }
  let!(:account)   { create :account, email: 'test@gmail.com', profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:profile)   { create :candidate_profile, name: 'Test Testowski' }
  let!(:domain)    { create :domain, name: 'some-domain', profile: profile }
  let!(:visit1)    { domain.visits.create }

  before do
    login_as_admin(admin)
  end

  describe '#index' do
    before { click_on 'Domains' }

    specify do
      expect(page).to have_content SERVER_IP
      expect(page).to have_link 'some-domain.example.com'
      expect(page).to have_link 'test@gmail.com', href: admin_account_path(account)
      expect(page).to have_content '1'
    end
  end

  describe '#show' do
    before { visit admin_domain_path(domain) }

    describe 'general info' do
      it 'should display domain name' do
        visit admin_domain_path(domain)
        expect(page).to have_link 'some-domain.example.com'
      end
    end

    describe 'See list of visits - by month' do
      before do
        domain.visits.create created_at: 3.months.ago
        domain.visits.create created_at: 3.months.ago
        domain.visits.create created_at: 2.months.ago
        domain.visits.create created_at: 2.months.ago
        domain.visits.create created_at: 2.months.ago
        domain.visits.create created_at: 1.month.ago
        domain.visits.create created_at: Time.now

        visit admin_domain_path(domain)
      end

      it 'should display the chart' do
        [ { created_at: 3.months.ago.beginning_of_month.to_date.to_json, count: 2 },
          { created_at: 2.months.ago.beginning_of_month.to_date.to_json, count: 3 },
          { created_at: 1.month.ago.beginning_of_month.to_date.to_json, count: 1 },
          { created_at: 0.months.ago.beginning_of_month.to_date.to_json, count: 2 }
        ].each do |hash|
          expect(page).to have_selector "#chart[data-records*='\"created_at\":#{hash[:created_at]},\"count\":#{hash[:count]}']"
        end
      end
    end

    describe 'See list of visits - by week' do
      before do
        domain.visits.create created_at: 3.weeks.ago
        domain.visits.create created_at: 3.weeks.ago
        domain.visits.create created_at: 2.weeks.ago
        domain.visits.create created_at: 2.weeks.ago
        domain.visits.create created_at: 2.weeks.ago
        domain.visits.create created_at: 1.week.ago
        domain.visits.create created_at: Time.now

        visit admin_domain_path(domain, period: :week)
      end

      it 'should display the chart' do
        [ { created_at: 3.weeks.ago.beginning_of_week.to_date.to_json, count: 2 },
          { created_at: 2.weeks.ago.beginning_of_week.to_date.to_json, count: 3 },
          { created_at: 1.week.ago.beginning_of_week.to_date.to_json, count: 1 },
          { created_at: 0.weeks.ago.beginning_of_week.to_date.to_json, count: 2 }
        ].each do |hash|
          expect(page).to have_selector "#chart[data-records*='\"created_at\":#{hash[:created_at]},\"count\":#{hash[:count]}']"
        end
      end
    end
  end

  describe 'links to switch between stats modes' do
    specify 'show page' do
      visit admin_domain_path(domain)
      expect(page).to have_link 'See stats by week', href: admin_domain_path(domain, period: :week)

      visit admin_domain_path(domain, period: :week)
      expect(page).to have_link 'See stats by month', href: admin_domain_path(domain)
    end
  end

  describe 'Create' do
    before { visit new_admin_domain_path }

    specify 'valid' do
      within '#new_domain' do
        select 'Test Testowski', from: 'Profile'
        fill_in 'Name', with: 'domain'
        expect(page).to have_unchecked_field 'Internal'
      end
      click_button 'Create Domain'

      expect(page).to have_content 'Domain was successfully created.'
    end

    specify 'invalid' do
      click_button 'Create Domain'
      expect(page).to have_content "can't be blank"
    end
  end

  describe 'Update' do
    let!(:profile1) { create(:candidate_profile) }
    let(:domain)    { create(:domain, profile: profile1) }

    before { visit edit_admin_domain_path(domain) }

    specify 'success' do
      within "#edit_domain_#{domain.id}" do
        select 'Test Testowski', from: 'Profile'
        fill_in 'Name', with: 'domain'
        uncheck 'Internal'
      end

      click_button 'Update Domain'

      expect(page).to have_content 'Domain was successfully updated.'
    end

    specify 'failure' do
      within "#edit_domain_#{domain.id}" do
        fill_in 'Name', with: ''
      end

      click_button 'Update Domain'

      expect(page).to have_content "can't be blank"
    end
  end

  describe 'Destroy' do
    let(:domain) { create(:domain) }

    before do
      allow_any_instance_of(Domain).to receive(:can_destroy?).and_return(can_destroy?)
      visit admin_domain_path(domain)
    end

    context 'success' do
      let(:can_destroy?) { true }

      specify do
        click_on 'Delete'
        expect(page).to have_content 'Domain was successfully deleted.'
      end
    end

    context 'failure' do
      let(:can_destroy?) { false }

      specify do
        click_on 'Delete'
        expect(page).to have_content "Can't remove this domain."
      end
    end
  end
end
