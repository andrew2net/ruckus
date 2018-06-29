require 'rails_helper'

describe 'Account' do
  let(:admin) { create :admin }

  before { login_as_admin(admin) }

  specify 'navbar links' do
    visit admin_accounts_path
    find('a.navbar-brand').click
    expect(current_path).to eq(admin_root_path)
    click_on 'Accounts'
    expect(current_path).to eq(admin_accounts_path)
    expect(page).to have_css('li a.active', text: 'Accounts')
  end

  describe 'Index' do
    let!(:account) do
      create :account, email:           'john@gmail.com',
                       created_at:      Time.parse('14/08/2015 16:30'),
                       last_sign_in_at: Time.parse('15/08/2015 16:30'),
                       profile:         profile
    end
    let!(:ownership) { create :ownership, profile: profile, account: account }
    let!(:profile)   { create :candidate_profile, first_name: 'John', last_name: 'Smith', premium_by_default: true }
    let!(:visit1)    { profile.domain.visits.create created_at: Time.parse('16/08/2015 16:30') }
    let!(:visit2)    { profile.domain.visits.create created_at: Time.parse('17/08/2015 16:30') }

    before { visit admin_accounts_path }

    it 'should have account' do
      expect(page).to have_content 'john@gmail.com'
      expect(page).to have_content '08/14/2015'
      expect(page).to have_content '08/15/2015'
      expect(page).to have_content '08/17/2015'
      expect(page).to have_no_content '08/16/2015'
    end
  end

  describe 'Create' do
    before do
      visit admin_accounts_path
      click_on 'New'
    end
    context 'valid' do
      it 'should create Account' do
        within '#new_account' do
          fill_in 'Email', with: 'user@user.com'
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
        end
        click_button 'Create Account'
        expect(page).to have_content 'Account was successfully created.'
      end
    end

    context 'invalid' do
      it 'should not create Account' do
        click_button 'Create Account'
        expect(page).to have_content 'New Account'
      end
    end
  end

  describe 'Activate/Deactivate' do
    let!(:account) { create :account, profile: profile, deleted_at: deleted_at }
    let!(:profile) { create :candidate_profile, premium_by_default: true }

    describe 'Activate' do
      let(:deleted_at) { Time.now }
      specify do
        visit admin_accounts_path(status: :all)
        click_on 'Activate'

        expect(account.reload.deleted_at).to be_nil
      end
    end

    describe 'Deactivate' do
      let(:deleted_at) { nil }
      specify do
        visit admin_accounts_path
        click_on 'Deactivate'

        expect(account.reload.deleted_at).to be_present
      end
    end
  end

  describe 'Login as account' do
    let!(:profile) { create :candidate_profile, premium_by_default: true }
    let!(:account) { create :account, profile: profile }
    specify 'Login' do
      visit admin_accounts_path
      click_on 'Login'

      expect(current_path).to eq profile_root_path
      expect(page).to have_content profile.domain.name # make sure it's the right one
    end
  end

  describe 'See list of logins by month' do
    let(:profile)  { create :candidate_profile }
    let!(:account) { create :account, profile: profile }

    before do
      account.logins.create created_at: 3.months.ago
      account.logins.create created_at: 3.months.ago
      account.logins.create created_at: 2.months.ago
      account.logins.create created_at: 2.months.ago
      account.logins.create created_at: 2.months.ago
      account.logins.create created_at: 1.month.ago
      account.logins.create created_at: Time.now

      visit admin_account_path(account)
    end

    it 'should display the chart' do
      [ { created_at: 3.months.ago.beginning_of_month.to_date.to_json, count: 2 },
        { created_at: 2.months.ago.beginning_of_month.to_date.to_json, count: 3 },
        { created_at: 1.month.ago.beginning_of_month.to_date.to_json, count: 1 },
        { created_at: 0.months.ago.beginning_of_month.to_date.to_json, count: 1 }
      ].each do |hash|
        expect(page).to have_selector "#chart[data-records*='\"created_at\":#{hash[:created_at]},\"count\":#{hash[:count]}']"
      end
    end
  end

  describe 'See list of logins by week' do
    let(:profile)  { create :candidate_profile }
    let!(:account) { create :account, profile: profile }

    before do
      account.logins.create created_at: 3.weeks.ago
      account.logins.create created_at: 3.weeks.ago
      account.logins.create created_at: 2.weeks.ago
      account.logins.create created_at: 2.weeks.ago
      account.logins.create created_at: 2.weeks.ago
      account.logins.create created_at: 1.week.ago
      account.logins.create created_at: Time.now

      visit admin_account_path(account, period: :week)
    end

    it 'should display the chart' do
      [ { created_at: 3.weeks.ago.beginning_of_week.to_date.to_json, count: 2 },
       { created_at: 2.weeks.ago.beginning_of_week.to_date.to_json, count: 3 },
       { created_at: 1.week.ago.beginning_of_week.to_date.to_json, count: 1 },
       { created_at: 0.weeks.ago.beginning_of_week.to_date.to_json, count: 1 }
      ].each do |hash|
        expect(page).to have_selector "#chart[data-records*='\"created_at\":#{hash[:created_at]},\"count\":#{hash[:count]}']"
      end
    end
  end

  describe 'Donations' do
    let!(:profile1)     { create :candidate_profile, name: 'John Smith', premium_by_default: true }
    let!(:profile2)     { create :candidate_profile, name: 'Bob Marley', premium_by_default: true }
    let!(:account1)     { create :account, profile: profile1 }
    let!(:account2)     { create :account, profile: profile2 }
    let!(:ownership1)   { create :ownership, profile: profile1, account: account1 }
    let!(:ownership2)   { create :ownership, profile: profile2, account: account2 }
    let!(:de_account_1) { create :de_account, profile: profile1 }
    let!(:de_account_2) { create :de_account, profile: profile2 }
    let!(:donation1) do
      create(:donation, amount:           5,
                        profile:          profile1,
                        donor_first_name: 'Mark',
                        donor_last_name:  'Bark')
    end
    let!(:donation2) do
      create(:donation, amount:           25,
                        profile:          profile2,
                        donor_first_name: 'Arny',
                        donor_last_name:  'Barny')
    end

    before do
      visit admin_accounts_path
    end

    it 'should display totals' do
      expect(page).to have_content 'Total number of accounts: 2'
      expect(page).to have_content 'Total donations raised: $30.00'
    end

    it 'should display donations list' do
      expect(page).to have_content '$5'
      expect(page).to have_content '$25'
    end
  end

  describe 'chart of signups by month' do
    before do
      [3, 3, 2, 2, 2, 1].each do |n|
        create(:account, created_at: n.months.ago, profile: create(:candidate_profile))
      end
      create(:account, profile: create(:candidate_profile) )

      visit admin_accounts_path
    end

    it 'should display the chart' do
      [ { created_at: 3.months.ago.beginning_of_month.to_date.to_json, count: 2 },
        { created_at: 2.months.ago.beginning_of_month.to_date.to_json, count: 3 },
        { created_at: 1.month.ago.beginning_of_month.to_date.to_json, count: 1 },
        { created_at: 0.months.ago.beginning_of_month.to_date.to_json, count: 1 }
      ].each do |hash|
        expect(page).to have_selector "#chart[data-records*='\"created_at\":#{hash[:created_at]},\"count\":#{hash[:count]}']"
      end
    end
  end

  describe 'chart of signups by week' do
    before do
      [3, 3, 2, 2, 2, 1].each do |n|
        create(:account, created_at: n.weeks.ago, profile: create(:candidate_profile))
      end
      create(:account, profile: create(:candidate_profile))

      visit admin_accounts_path(period: :week)
    end

    it 'should display the chart' do
      [ { created_at: 3.weeks.ago.beginning_of_week.to_date.to_json, count: 2 },
        { created_at: 2.weeks.ago.beginning_of_week.to_date.to_json, count: 3 },
        { created_at: 1.week.ago.beginning_of_week.to_date.to_json, count: 1 },
        { created_at: 0.weeks.ago.beginning_of_week.to_date.to_json, count: 1 }
      ].each do |hash|
        expect(page).to have_selector "#chart[data-records*='\"created_at\":#{hash[:created_at]},\"count\":#{hash[:count]}']"
      end
    end
  end

  describe 'links to switch between stats modes' do
    let(:profile)    { create :candidate_profile }
    let(:account)    { create :account, profile: profile }

    describe 'index page' do
      specify 'stats controls' do
        visit admin_accounts_path
        expect(page).to have_link 'See stats by week', href: admin_accounts_path(period: :week)

        visit admin_accounts_path(period: :week)
        expect(page).to have_link 'See stats by month', href: admin_accounts_path
      end

      specify 'filter controls' do
        visit admin_accounts_path

        expect(page).to have_link 'Active', href: admin_accounts_path
        expect(page).to have_link 'Inactive', href: admin_accounts_path(status: :inactive)
        expect(page).to have_link 'All', href: admin_accounts_path(status: :all)
      end
    end

    specify 'show page' do
      visit admin_account_path(account)
      expect(page).to have_link 'See stats by week', href: admin_account_path(account, period: :week)

      visit admin_account_path(account, period: :week)
      expect(page).to have_link 'See stats by month', href: admin_account_path(account)
    end
  end

  describe 'account show page' do
    let!(:ownership) { create :ownership, profile: profile, account: account }
    let(:account) do
      create :account, created_at: Time.parse('2010-09-23 22:08:11 +0300'),
                       current_sign_in_at: Time.parse('2013-12-08 15:53:10 +0200'),
                       current_sign_in_ip: '123.321.123.321',
                       email: 'camilla@cormierstehr.biz',
                       last_sign_in_at: Time.parse('2012-10-17 15:34:17 +0300'),
                       last_sign_in_ip: '222.333.444.555',
                       remember_created_at: Time.parse('2008-11-09 03:25:49 +0200'),
                       reset_password_sent_at: Time.parse('2009-12-29 11:59:54 +0200'),
                       sign_in_count: 62,
                       updated_at: Time.parse('2004-06-16 07:27:39 +0300'),
                       profile: profile
    end
    let!(:profile) do
      create :candidate_profile,
                       biography: 'Aspernatur possimus rerum hic veritatis aperiam ipsum numquam consequatur.',
                       address_1: '4597 Daphnee Corner',
                       address_2: '613 Nicolas Prairie',
                       campaign_disclaimer: 'OCZFKKNZ',
                       campaign_organization: 'EEGOLKNI',
                       campaign_organization_identifier: 'OWTBOVQO',
                       campaign_website: 'OPIFYNQD',
                       city: 'Orrinshire',
                       contact_city: 'Johnnyberg',
                       contact_state: 'AZ',
                       contact_zip: '34930',
                       created_at: Time.parse('2013-07-10 17:39:27 +0300'),
                       district: 'IMFKNFAA',
                       first_name: 'Dasia',
                       last_name: 'Stracke',
                       office: 'PWEEHRLG',
                       party_affiliation: 'JUUZMXTT',
                       phone: '138-089-3330',
                       tagline: 'ZBMHITTN',
                       state: 'SD',
                       updated_at: Time.parse('2013-10-15 17:39:27 +0300'),
                       biography_on: true,
                       donation_notifications_on: false,
                       donations_on: false,
                       events_on: false,
                       facebook_on: false,
                       issues_on: false,
                       media_on: true,
                       press_on: true,
                       questions_on: false,
                       signup_notifications_on: true,
                       social_feed_on: false,
                       weekly_report_on: false
    end

    before { visit admin_account_path(account) }

    specify 'main info' do
      within '#main' do
        expect(page).to have_content '09/23/2010'
        expect(page).to have_content '12/08/2013'
        expect(page).to have_content '123.321.123.321'
        expect(page).to have_content 'camilla@cormierstehr.biz'
        expect(page).to have_content '10/17/2012'
        expect(page).to have_content '222.333.444.555'
        expect(page).to have_content '11/09/2008'
        expect(page).to have_content '12/29/2009'
        expect(page).to have_content '62'
      end
    end

    specify 'display links to profiles' do
      within '#profiles' do
        expect(page).to have_link(profile.id, href: admin_account_profile_path(account, profile))
        expect(page).to have_selector('td', text: profile.name)
        expect(page).to have_selector('td', text: profile.created_at)
      end
    end

    describe 'display Not Specified for empty date fields' do
      let(:account) { create :account, :without_timestamps }

      specify do
        visit admin_account_path(account)

        within '#main' do
          expect(page).to have_content 'Not specified', count: 7
        end
      end
    end
  end
end
