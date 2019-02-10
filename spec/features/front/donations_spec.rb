require 'rails_helper'

describe 'Donations' do
  let!(:profile)   { create :candidate_profile, credit_card_holder: nil, donations_on: true, premium_by_default: true }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:de_account) do
    create :de_account, profile:            profile,
                        agreements:         ['agr 1', 'agr 2', ''],
                        contribution_limit: 1325,
                        is_active_on_de:    is_active_on_de
  end
  let!(:donation) { build(:donation, profile: profile) }
  let(:is_active_on_de) { true }

  before { visit with_subdomain(profile.domain.name) }

  it 'should init slider', :js do
    click_link 'Donate'
    expect(find('#donation-step-1')['style']).not_to be_empty
    find('.mfp-close').click
    click_link 'Donate'
    expect(find('#donation-step-1')['style']).not_to be_empty
  end

  describe 'should hide donate button if DE account not active' do
    let(:is_active_on_de) { false }
    specify do
      visit with_subdomain(profile.domain.name)
      expect(page).to have_no_link 'Donate'
    end
  end

  it 'should hide when off' do
    profile.update(donations_on: false)
    visit current_url
    expect(page).to have_no_link('Donate', href: new_front_profile_donation_path(profile))
  end

  describe 'show/hide employer fields' do
    describe 'employer name' do
      it 'should show employer name' do
        de_account.update(show_employer_name: true)
        click_link 'Donate'
        within '#donation-step-2' do
          expect(page).to have_field 'donation_employer_name'
        end
      end

      it 'should hide employer name' do
        de_account.update(show_employer_name: false)
        click_link 'Donate'
        within '#donation-step-2' do
          expect(page).to have_no_field 'donation_employer_name'
        end
      end
    end

    describe 'employer address' do
      it 'should show employer address' do
        de_account.update(show_employer_address: true)
        click_link 'Donate'
        within '#donation-step-2' do
          expect(page).to have_field 'donation_employer_address'
          expect(page).to have_field 'donation_employer_city'
          expect(page).to have_field 'donation_employer_state'
          expect(page).to have_field 'donation_employer_zip'
        end
      end

      it 'should hide employer address' do
        de_account.update(show_employer_address: false)
        click_link 'Donate'
        within '#donation-step-2' do
          expect(page).to have_no_field 'donation_employer_address'
          expect(page).to have_no_field 'donation_employer_city'
          expect(page).to have_no_field 'donation_employer_state'
          expect(page).to have_no_field 'donation_employer_zip'
        end
      end
    end

    describe 'occupation' do
      it 'should show employer occupation' do
        de_account.update(show_occupation: true)
        click_link 'Donate'
        within '#donation-step-2' do
          expect(page).to have_field 'donation_employer_occupation'
        end
      end

      it 'should hide employer occupation' do
        de_account.update(show_occupation: false)
        click_link 'Donate'
        within '#donation-step-2' do
          expect(page).to have_no_field 'donation_employer_occupation'
        end
      end
    end
  end

  specify 'donate - go through all steps & display errors', :unstub_de, :js do
    # Todo: Probably better to do 4 flows:
    # 1) Insert correct info (& make sure modal gets closed)
    # 2) Insert invalid CC Number (& make sure modal is opened & errors are displayed)
    # 3) Insert amount manually (like $123)
    # 4) Select amount from the list

    # But for now don't like that there will be 500 lines of similar steps.

    allow_any_instance_of(De::DonationCreator).to receive(:process).and_return([[:base, 'Credit card not valid']])
    allow_any_instance_of(DeAccount).to receive(:values_for_donation_modal).and_return([23, 40, 145, 280, 386])
    click_link 'Donate'

    #step 1
    expect(page).to have_css('span.current', text: 1)
    expect(page).not_to have_css('span.current', text: 2)
    expect(page).not_to have_css('span.current', text: 3)

    within '#donation-step-1' do
      expect(page).to have_css('h2', text: 'Customer Information')

      click_button 'Next'

      expect(page).to have_css '#donation_donor_first_name.error'
      expect(page).not_to have_css '#donation_donor_middle_name.error'
      expect(page).to have_css '#donation_donor_last_name.error'
      expect(page).to have_css '#donation_donor_email.error'
      expect(page).to have_css '#donation_donor_phone.error'
      expect(page).to have_css '#donation_donor_address_1.error'
      expect(page).not_to have_css '#donation_donor_address_2.error'
      expect(page).to have_css '#donation_donor_city.error'
      expect(page).to have_css '#donation_donor_zip.error'

      page.fill_in 'donation_donor_first_name', with: donation.donor_first_name
      page.fill_in 'donation_donor_middle_name', with: donation.donor_middle_name
      page.fill_in 'donation_donor_last_name', with: donation.donor_last_name
      page.fill_in 'donation_donor_email', with: donation.donor_email
      page.fill_in 'donation_donor_phone', with: donation.donor_phone
      page.fill_in 'donation_donor_address_1', with: donation.donor_address_1
      page.fill_in 'donation_donor_address_2', with: donation.donor_address_2
      page.fill_in 'donation_donor_city', with: donation.donor_city
      page.fill_in 'donation_donor_zip', with: donation.donor_zip
      page.select 'NY', from: 'donation_donor_state'

      click_button 'Next'
    end

    #step 2
    expect(page).to have_css('span.completed', text: 1)
    expect(page).to have_css('span.current', text: 2)
    expect(page).to have_css('span.current', text: 2)
    expect(page).not_to have_css('span.current', text: 3)

    within '#donation-step-2' do
      expect(page).to have_css('h2', text: 'Employer Information')

      click_button 'Next'

      expect(page).to have_css '#donation_employer_name.error'
      expect(page).to have_css '#donation_employer_occupation.error'
      expect(page).to have_css '#donation_employer_address.error'
      expect(page).to have_css '#donation_employer_city.error'
      expect(page).to have_css '#donation_employer_zip.error'

      page.fill_in 'donation_employer_name', with: donation.employer_name
      page.fill_in 'donation_employer_occupation', with: donation.employer_occupation
      page.fill_in 'donation_employer_address', with: donation.employer_address
      page.fill_in 'donation_employer_city', with: donation.employer_city
      page.fill_in 'donation_employer_zip', with: donation.employer_zip
      page.select 'NY', from: 'donation_employer_state'

      click_button 'Next'
    end

    #step 3
    expect(page).to have_css('span.completed', text: 1)
    expect(page).to have_css('span.completed', text: 2)
    expect(page).to have_css('span.current', text: 3)

    within '#donation-step-3' do

      expect(page).to have_content '(maximum contribution limit is $1,325.00)'
      expect(page).to have_css('h2', text: 'Payment Information')
      within '#donate-terms' do
        expect(page).to have_css 'li', text: 'agr 1'
        expect(page).to have_css 'li', text: 'agr 2'
        expect(page).to have_css '.agreement', count: 2
      end

      within '.dontate-amount' do
        # stubbed values
        expect(page).to have_content '$23'
        expect(page).to have_content '$40'
        expect(page).to have_content '$145'
        expect(page).to have_content '$280'
        expect(page).to have_content '$386'
      end

      click_button 'Donate'

      expect(page).to have_css '#donation_credit_card_attributes_number.error'
      expect(page).to have_css '#donation_credit_card_attributes_cvv.error'

      page.fill_in 'donation_credit_card_attributes_number', with: donation.credit_card.number
      page.fill_in 'donation_credit_card_attributes_cvv', with: donation.credit_card.cvv
      page.select '01', from: 'donation_credit_card_attributes_month'
      page.select '2025', from: 'donation_credit_card_attributes_year'

      click_button 'Donate'
      expect(page).to have_selector('.donate-amount-error', count: 1)

      page.find('#donation_amount_other').click
      page.fill_in 'donation_amount', with: '40'

      click_button 'Donate'
    end

    expect(page).to have_content 'CREDIT CARD NOT VALID'

    # successful donation
    allow_any_instance_of(De::DonationCreator).to receive(:process).and_return('line_items' => [
      'transaction_guid' => 'transaction_guid',
      'transaction_uri'  => 'transaction_uri'
    ])

    within '#donation-step-3' do
      click_button 'Donate'
    end

    expect(page).to have_content 'THANK YOU FOR YOUR DONATION!'
  end
end
