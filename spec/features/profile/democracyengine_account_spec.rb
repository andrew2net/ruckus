require 'rails_helper'
require 'deapi'

describe 'Settings' do
  let!(:account) { create :account, profile: profile }
  let!(:profile) { create(:candidate_profile, name: 'Bob Sinclar', donations_on: donations_on) }
  let(:donations_on) { true }

  before { login_as(account, scope: :account) }

  describe 'account inactive msg' do
    let!(:de_account) { create(:de_account, profile: profile, is_active_on_de: is_active_on_de) }

    before { visit edit_profile_page_option_path }

    context 'account is inactive' do
      let(:is_active_on_de) { false }
      specify do
        expect(page).to have_content 'awaiting approval'
        expect(page).not_to have_link 'delete'
      end
    end

    context 'account is active' do
      let(:is_active_on_de) { true }
      specify do
        expect(page).to have_no_content 'awaiting approval'
        expect(page).not_to have_link 'delete'
      end
    end

    context 'account is active & donations off' do
      let(:is_active_on_de) { true }
      let(:donations_on) { false }

      specify do
        expect(page).to have_no_content 'awaiting approval'
        expect(page).to have_link 'delete'
      end
    end
  end

  describe 'show/hide Donations switch' do
    specify 'without account' do
      visit edit_profile_page_option_path
      expect(page).to have_no_css '#profile_donations_on'
    end

    context 'with account' do
      let!(:de_account) { create(:de_account, profile: profile, is_active_on_de: active?) }

      before { visit edit_profile_page_option_path }

      context 'inactive' do
        let(:active?) { false }
        specify { expect(page).to have_no_css '#profile_donations_on' }
      end

      context 'inactive' do
        let(:active?) { true }
        specify { expect(page).to have_css '#profile_donations_on' }
      end
    end
  end

  describe 'New DE Account' do
    before { visit edit_profile_page_option_path }

    it 'should have required links' do
      click_on 'Connect Account'
      expect(page).to have_link 'Cancel', href: edit_profile_page_option_path
      expect(page).to have_link 'Terms of Service'
    end

    context 'prepopulates fields with info that has already been collected' do
      let!(:profile) do
        create(:candidate_profile, name:                             'Bob Sinclar',
                                   address_1:                        'Some Street',
                                   office:                           'Governor',
                                   party_affiliation:                'Some Party',
                                   tagline:                          'world peace',
                                   district:                         '10th district',
                                   phone:                            '123-456-7890',
                                   contact_city:                     'Denver',
                                   contact_state:                    'CO',
                                   contact_zip:                      '54321',
                                   campaign_disclaimer:              'Paid for by Smith',
                                   campaign_organization_identifier: 'FEC ID',
                                   campaign_organization:            'Committee Name')
      end

      specify do
        click_on 'Connect Account'

        expect(find('#de_account_contact_state').value).to eq 'CO'
        expect(page).to have_field 'de_account_email',                        with: account.email
        expect(page).to have_field 'de_account_account_full_name',            with: 'Bob Sinclar'
        expect(page).to have_field 'de_account_account_address',              with: 'Some Street'
        expect(page).to have_field 'de_account_account_city',                 with: 'Denver'
        expect(page).to have_field 'de_account_account_district_or_locality', with: '10th district'
        expect(page).to have_field 'de_account_account_campaign_disclaimer',  with: 'Paid for by Smith'
        expect(page).to have_field 'de_account_account_committee_name',       with: 'Committee Name'
        expect(page).to have_field 'de_account_account_committee_id',         with: 'FEC ID'
        expect(page).to have_field 'de_account_account_party',                with: 'Some Party'
        expect(page).to have_field 'de_account_contact_first_name',           with: 'Bob'
        expect(page).to have_field 'de_account_contact_last_name',            with: 'Sinclar'
        expect(page).to have_field 'de_account_contact_email',                with: account.email
        expect(page).to have_field 'de_account_contact_phone',                with: '123-456-7890'
        expect(page).to have_field 'de_account_contact_address',              with: 'Some Street'
        expect(page).to have_field 'de_account_contact_city',                 with: 'Denver'
        expect(page).to have_field 'de_account_contact_zip',                  with: '54321'
      end
    end

    context 'can not create new account with invalid data', :js do
      before do
        hide_welcome_screen
        expect(page).to have_link 'Connect Account', href: new_profile_de_account_path
        expect(DEApi).not_to receive(:create_recipient)
      end

      specify do
        click_on 'Connect Account'

        within '#new_de_account_form' do
          fill_in 'de_account_email',                            with: ''
          fill_in 'de_account_password',                         with: ''
          fill_in 'de_account_password_confirmation',            with: ''
          fill_in 'de_account_account_full_name',                with: ''
          fill_in 'de_account_account_committee_name',           with: ''
          fill_in 'de_account_account_committee_id',             with: ''
          fill_in 'de_account_account_address',                  with: ''
          fill_in 'de_account_account_city',                     with: ''
          fill_in 'de_account_account_zip',                      with: ''
          fill_in 'de_account_account_district_or_locality',     with: ''
          fill_in 'de_account_account_campaign_disclaimer',      with: ''
          fill_in 'de_account_account_party',                    with: ''
          fill_in 'de_account_contact_first_name',               with: ''
          fill_in 'de_account_contact_last_name',                with: ''
          fill_in 'de_account_contact_email',                    with: ''
          fill_in 'de_account_contact_phone',                    with: ''
          fill_in 'de_account_contact_address',                  with: ''
          fill_in 'de_account_contact_city',                     with: ''
          fill_in 'de_account_contact_zip',                      with: ''
          fill_in 'de_account_bank_account_name',                with: ''
          fill_in 'de_account_bank_routing_number',              with: ''
          fill_in 'de_account_bank_account_number',              with: ''
          fill_in 'de_account_bank_account_number_confirmation', with: ''
          find('label[for=de_account_terms]').click
          click_on 'Finish'
        end

        within '#new_de_account_form' do
          #"can't be blank" warnings
          expect(page).to have_css '#de_account_email + .help-inline'

          expect(page).to have_css '#de_account_account_full_name + .help-inline'
          expect(page).to have_css '#de_account_account_committee_name + .help-inline'
          expect(page).to have_css '#de_account_account_committee_id + .help-inline'
          expect(page).to have_css '#de_account_account_address + .help-inline'
          expect(page).to have_css '#de_account_account_city + .help-inline'
          expect(page).to have_css '#de_account_account_zip + .help-inline'
          expect(page).to have_css '#de_account_account_campaign_disclaimer + .help-inline'
          expect(page).to have_css '#de_account_account_party + .help-inline'

          expect(page).to have_css '#de_account_contact_first_name + .help-inline'
          expect(page).to have_css '#de_account_contact_last_name + .help-inline'
          expect(page).to have_css '#de_account_contact_email + .help-inline'
          expect(page).to have_css '#de_account_contact_phone + .help-inline'
          expect(page).to have_css '#de_account_contact_address + .help-inline'
          expect(page).to have_css '#de_account_contact_city + .help-inline'
          expect(page).to have_css '#de_account_contact_zip + .help-inline'

          expect(page).to have_css '#de_account_bank_account_name + .help-inline'
          expect(page).to have_css '#de_account_bank_routing_number + .help-inline'
          expect(page).to have_css '#de_account_bank_account_number + .help-inline'
          expect(page).to have_css '#de_account_bank_account_number_confirmation + .help-inline'
        end
      end
    end

    describe 'fill in entire form', :js do
      before do
        hide_welcome_screen
        # correct info
        expect(page).to have_link 'Connect Account', href: new_profile_de_account_path
        expect(page).to have_no_content 'To update your bank account or other information'

        click_on 'Connect Account'

        within '#new_de_account_form' do
          fill_in 'de_account_email',                        with: 'whatever@gmail.com'
          fill_in 'de_account_password',                     with: '12345678'
          fill_in 'de_account_password_confirmation',        with: '12345678'
          fill_in 'de_account_account_full_name',            with: 'Bob Sinclar'
          fill_in 'de_account_account_committee_name',       with: 'The Committee'
          fill_in 'de_account_account_committee_id',         with: '12345678'
          fill_in 'de_account_account_address',              with: 'any street'
          fill_in 'de_account_account_city',                 with: 'New York City'
          fill_in 'de_account_account_zip',                  with: '12345'
          fill_in 'de_account_account_district_or_locality', with: 'DC'
          fill_in 'de_account_account_campaign_disclaimer',  with: 'Some Company'
          fill_in 'de_account_account_party',                with: 'Some Party'
          fill_in 'Contribution Limit',                                   with: '2500'

          select 'NY', from: 'de_account_account_state'
          select 'Local Candidate', from: 'Recipient Type'

          find('label[for=de_account_show_employer_name]').click
          find('label[for=de_account_show_employer_address]').click
          find('label[for=de_account_show_occupation]').click

          fill_in 'de_account_agreements', with: 'agreement 1'
          find('#de_account_agreements').click

          fill_in 'de_account_bank_account_name',                with: 'Daniel'
          fill_in 'de_account_bank_routing_number',              with: '12345678'
          fill_in 'de_account_bank_account_number',              with: '12345678'
          fill_in 'de_account_bank_account_number_confirmation', with: '12345678'
          fill_in 'de_account_contact_first_name',               with: 'John'
          fill_in 'de_account_contact_last_name',                with: 'Smith'
          fill_in 'de_account_contact_email',                    with: 'the_email@gmail.com '
          fill_in 'de_account_contact_phone',                    with: '123-123-1234'
          fill_in 'de_account_contact_address',                  with: 'address'
          fill_in 'de_account_contact_city',                     with: 'the city'

          select 'CO', from: 'de_account_contact_state'

          click_on 'Save'
          fill_in 'de_account_contact_zip', with: '12345'

          find('label[for=de_account_terms]').click
        end
      end

      it 'can create new account with valid data' do
        expect(DEApi).to receive(:create_recipient)

        within '#new_de_account_form' do
          click_on 'Finish'
        end

        expect(page).to have_content 'Bob Sinclar'
        expect(page).not_to have_link 'Connect Account'
        expect(page).to have_content 'To update your bank account or other information'
      end

      it 'rejects the form if bank account does not match' do
        within '#new_de_account_form' do
          fill_in 'de_account_bank_account_number', with: '12345678'
          fill_in 'de_account_bank_account_number_confirmation', with: '5'

          click_on 'Finish'
        end

        expect(page).to have_content "doesn't match"
      end

      it 'rejects the form if password does not match' do
        within '#new_de_account_form' do
          fill_in 'de_account_password', with: '12345678'
          fill_in 'de_account_password_confirmation', with: '5'

          click_on 'Finish'
        end

        expect(page).to have_content "doesn't match"
      end

      it 'persists the filled in data if there was an error' do
        within '#new_de_account_form' do
          fill_in 'de_account_password_confirmation', with: '' # trigger error
          click_on 'Finish'
        end

        expect(page).to have_field 'de_account_account_committee_name', with: 'The Committee'
        expect(page).to have_field 'de_account_account_committee_id', with: '12345678'
      end

      it 'displays DE account info' do
        # for some reason when IR is included through inherit_resources method - this test crashes,
        # and only works when IR is required in Base controller
        # need to fix later
        within '#new_de_account_form' do
          click_on 'Finish'
        end

        allow_any_instance_of(DeAccount).to receive(:uuid).and_return('recipient_id_123')
        click_on 'Bob Sinclar'
        expect(page).to have_content 'whatever@gmail.com'
        expect(page).to have_content 'Bob Sinclar'
        expect(page).to have_content 'recipient_id_123'
        expect(page).to have_content 'The Committee'
        expect(page).to have_content '12345678'
        expect(page).to have_content 'any street, New York City, NY, 12345'
        expect(page).to have_content 'Local candidate'
        expect(page).to have_content 'DC'
        expect(page).to have_content 'Some Company'
        expect(page).to have_content 'Some Party'
        expect(page).to have_content '$2,500.00'

        expect(page).to have_link 'click here', href: profile_builder_path(resources: :info)

        within '.show_employer_name' do
          expect(page).to have_content 'Yes'
        end

        within '.show_employer_address' do
          expect(page).to have_content 'Yes'
        end

        within '.show_employer_occupation' do
          expect(page).to have_content 'Yes'
        end

        expect(page).to have_content 'Daniel'
        expect(page).to have_content '12345678'
        expect(page).to have_content 'John Smith'
        expect(page).to have_content 'the_email@gmail.com '
        expect(page).to have_content '123-123-1234'
        expect(page).to have_content 'address, the city, CO, 12345'
      end
    end
  end
end
