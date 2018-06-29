require 'rails_helper'

describe 'Admin::Account::PaymentAccounts' do
  let!(:admin) { create :admin }
  let!(:credit_card) { create :credit_card, last_four: '1111' }
  let!(:de_account) do
    create(:de_account,
           credit_card:                      credit_card,
           bank_account_name:                'JaidaDickinson',
           bank_account_number:              'FMRASPOE',
           bank_account_number_confirmation: 'FMRASPOE',
           bank_routing_number:              'RLMGDKQR',
           account_address:                  '4824 Terrance Center',
           account_campaign_disclaimer:      'WADQPKOR',
           account_committee_name:           'NikoBeahan',
           account_city:                     'Lake Keven',
           account_committee_id:             'AXKDREIQ',
           account_district_or_locality:     'NFJQRDII',
           account_recipient_kind:           'state_party',
           account_full_name:                'TerrellFritsch',
           account_party:                    'JYCEEANX',
           account_state:                    'NC',
           account_zip:                      '44892',
           contact_address:                  '51714 McCullough Isle',
           contact_city:                     'Lake Marilyne',
           contact_email:                    'furman.beer@schuppe.name',
           contact_first_name:               'Macey',
           contact_last_name:                'Hermiston',
           contact_phone:                    '(373)852-0868 x583',
           contact_state:                    'MO',
           is_active_on_de:                  true,
           show_employer_address:            true,
           show_employer_name:               false,
           show_occupation:                  true,
           contact_zip:                      '17998-2838',
           created_at:                       Time.parse('2011-01-01 20:21:51 +0200'),
           email:                            'laria_hudson@keelingemard.org',
           contribution_limit:               5,
           updated_at:                       Time.parse('2008-08-12 03:58:39 +0300'),
           uuid:                             'LXUNMJLV')
  end

  before { login_as_admin(admin) }

  specify 'Show payment account' do
    visit admin_payment_account_path(de_account)

    expect(page).to have_content 'JaidaDickinson'
    expect(page).to have_content 'FMRASPOE'
    expect(page).to have_content 'RLMGDKQR'
    expect(page).to have_content '4824 Terrance Center'
    expect(page).to have_content 'WADQPKOR'
    expect(page).to have_content 'NikoBeahan'
    expect(page).to have_content 'Lake Keven'
    expect(page).to have_content 'AXKDREIQ'
    expect(page).to have_content 'NFJQRDII'
    expect(page).to have_content 'state_party'
    expect(page).to have_content 'TerrellFritsch'
    expect(page).to have_content 'JYCEEANX'
    expect(page).to have_content 'NC'
    expect(page).to have_content '44892'
    expect(page).to have_content '51714 McCullough Isle'
    expect(page).to have_content 'Lake Marilyne'
    expect(page).to have_content 'furman.beer@schuppe.name'
    expect(page).to have_content 'Macey'
    expect(page).to have_content 'Hermiston'
    expect(page).to have_content '(373)852-0868 x583'
    expect(page).to have_content 'MO'
    expect(page).to have_content '17998-2838'
    expect(page).to have_content '01/01/2011'
    expect(page).to have_content 'laria_hudson@keelingemard.org'
    expect(page).to have_content '5'
    expect(page).to have_content '08/12/2008'
    expect(page).to have_content 'LXUNMJLV'
    expect(page).to have_selector '#is_active_on_de', text: 'Yes'
    expect(page).to have_selector '#show_employer_address', text: 'Yes'
    expect(page).to have_selector '#show_employer_name', text: 'No'
    expect(page).to have_selector '#show_occupation', text: 'Yes'
    expect(page).to have_content '1111'
  end

  describe 'Edit payment account' do
    before do
      visit edit_admin_payment_account_path(de_account)

      fill_in 'de_account[email]', with: email
      click_on 'Save'
    end

    context 'success' do
      let(:email) { 'cj@example.com' }

      specify do
        expect(page).to have_content 'was successfully updated'
        expect(page).to have_content email
      end
    end

    context 'failure' do
      let(:email) { '' }
      specify { expect(page).to have_content "can't be blank" }
    end
  end
end
