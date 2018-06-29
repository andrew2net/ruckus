require 'rails_helper'

describe 'Donor List' do
  let(:profile)     { create :candidate_profile }
  let!(:account)    { create :account, profile: profile }
  let!(:de_account) { create :de_account, profile: profile }

  before { login_as(account, scope: :account) }

  it 'should be accessible from dashboard' do
    visit profile_dashboard_path
    click_on 'Donor List'

    expect(current_path).to eq profile_donations_path
  end

  it 'should be accessible from settings menu' do
    visit edit_profile_page_option_path
    click_on 'Donors'

    expect(current_path).to eq profile_donations_path
  end

  describe 'display donors info' do
    let!(:donation1) do
      create(:donation, profile: profile,
                        donor_first_name: 'Bob',
                        donor_last_name: 'Smoth',
                        amount: 13)
    end
    let!(:donation2) do
      create(:donation, profile: profile,
                        donor_first_name: 'John',
                        donor_last_name: 'Smith',
                        amount: 33.22)
    end

    before { visit profile_donations_path }

    it 'should display list of donors' do
      expect(page).to have_content 'Bob Smoth'
      expect(page).to have_content 'John Smith'
      expect(page).to have_content '$13.00'
      expect(page).to have_content '$33.22'
      expect(page).to have_content donation1.created_at.to_s
      expect(page).to have_content donation2.created_at.to_s
    end

    it 'should display number of donors' do
      expect(page).to have_content '2 Donors'
    end

    it 'should have a hint' do
      expect(page).to have_content "This is a list of your donors to date. If you wish to export \
                                    or otherwise manipulate this data, please login to your"
    end
  end
end
