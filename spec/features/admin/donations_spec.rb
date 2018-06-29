require 'rails_helper'

describe 'Donations' do
  let!(:admin)      { create :admin }
  let!(:profile)    { create(:candidate_profile, name: 'John Smith') }
  let!(:account)    { create :account, profile: profile }
  let!(:de_account) { create(:de_account, profile: profile) }

  before do
    login_as_admin(admin)
  end

  describe '#index' do
    let!(:donation) do
      create(:donation, profile:          profile,
                        amount:           23,
                        donor_first_name: 'Dejah',
                        donor_last_name:  'Runte')
    end
    before { click_on 'Donations' }

    it 'should show list of donations' do
      expect(page).to have_content '$23.00'
      expect(page).to have_content 'Dejah Runte'
      expect(page).to have_link 'John Smith', with_subdomain(profile.domain.try(:name))
    end
  end

  describe 'charts' do
    describe 'chart of number of donations - by month' do
      before do
        create(:donation, profile: profile, created_at: 3.months.ago, amount: 15)
        create(:donation, profile: profile, created_at: 3.months.ago, amount: 12)

        create(:donation, profile: profile, created_at: 2.months.ago, amount: 1)
        create(:donation, profile: profile, created_at: 2.months.ago, amount: 2)
        create(:donation, profile: profile, created_at: 2.months.ago, amount: 6)

        create(:donation, profile: profile, created_at: 1.month.ago, amount: 6)

        create(:donation, profile: profile, created_at: Time.now, amount: 5)

        visit admin_donations_path
      end

      it 'should display the count chart' do
        [ { created_at: 3.months.ago.beginning_of_month.to_date.to_json, count: 2 },
          { created_at: 2.months.ago.beginning_of_month.to_date.to_json, count: 3 },
          { created_at: 1.month.ago.beginning_of_month.to_date.to_json, count: 1 },
          { created_at: 0.months.ago.beginning_of_month.to_date.to_json, count: 1 }
        ].each do |hash|
          expect(page).to have_selector "#chart[data-records*='\"created_at\":#{hash[:created_at]},\"count\":#{hash[:count]}']"
        end
      end

      it 'should display the amounts chart' do
        [ { created_at: 3.months.ago.beginning_of_month.to_date.to_json, amount: 27.0 },
          { created_at: 2.months.ago.beginning_of_month.to_date.to_json, amount: 9.0 },
          { created_at: 1.month.ago.beginning_of_month.to_date.to_json, amount: 6.0 },
          { created_at: 0.months.ago.beginning_of_month.to_date.to_json, amount: 5.0 }
        ].each do |hash|
          expect(page).to have_selector "#amounts_chart[data-records*='\"created_at\":#{hash[:created_at]},\"total_amount\":\"#{hash[:amount]}\"']"
        end
      end
    end

    describe 'See list of visits - by week' do
      before do
        create(:donation, profile: profile, created_at: 3.weeks.ago, amount: 34.0)
        create(:donation, profile: profile, created_at: 3.weeks.ago, amount: 12.0)

        create(:donation, profile: profile, created_at: 2.weeks.ago, amount: 16.0)
        create(:donation, profile: profile, created_at: 2.weeks.ago, amount: 12.0)
        create(:donation, profile: profile, created_at: 2.weeks.ago, amount: 23.0)

        create(:donation, profile: profile, created_at: 1.week.ago, amount: 1.0)

        create(:donation, profile: profile, created_at: Time.now, amount: 32.0)

        visit admin_donations_path(period: :week)
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

      it 'should display the chart' do
        [ { created_at: 3.weeks.ago.beginning_of_week.to_date.to_json, amount: 46.0 },
          { created_at: 2.weeks.ago.beginning_of_week.to_date.to_json, amount: 51.0 },
          { created_at: 1.week.ago.beginning_of_week.to_date.to_json, amount: 1.0 },
          { created_at: 0.weeks.ago.beginning_of_week.to_date.to_json, amount: 32.0 }
        ].each do |hash|
          expect(page).to have_selector "#amounts_chart[data-records*='\"created_at\":#{hash[:created_at]},\"total_amount\":\"#{hash[:amount]}\"']"
        end
      end
    end
  end

  describe 'links to switch between stats modes' do
    specify 'show page' do
      visit admin_donations_path
      expect(page).to have_link 'See stats by week', href: admin_donations_path(period: :week)

      visit admin_donations_path(period: :week)
      expect(page).to have_link 'See stats by month', href: admin_donations_path
    end
  end
end
