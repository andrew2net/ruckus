require 'rails_helper'

describe Admin::PaymentAccountsController do
  let(:admin) { create :admin }
  let!(:de_account) { create(:de_account) }

  before { sign_in admin }

  specify 'GET #show' do
    get :show, id: de_account.id
    expect(response).to render_template :show
  end

  specify 'GET #edit' do
    get :edit, id: de_account.id
    expect(response).to render_template :edit
  end

  describe 'PATCH #update' do
    let(:params) do
      {
        bank_account_name:                'JaidaDickinson',
        bank_account_number:              'FMRASPOE',
        bank_account_number_confirmation: 'FMRASPOE',
        bank_routing_number:              'RLMGDKQR',
        account_address:                  '4824 Terrance Center',
        account_campaign_disclaimer:      'WADQPKOR',
        account_committee_name:           'NikoBeahan',
        account_city:                     'Lake Keven',
        account_district_or_locality:     'NFJQRDII',
        account_recipient_kind:           'KMDBIJCH',
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
        show_employer_address:            true,
        show_employer_name:               false,
        show_occupation:                  true,
        contact_zip:                      '17998-2838',
        email:                            'laria_hudson@keelingemard.org',
        contribution_limit:               5,
        uuid:                             'LXUNMJLV'
      }
    end

    specify 'success' do
      patch :update, id: de_account.id, de_account: params

      expect(response).to redirect_to admin_payment_account_path(de_account)

      de_account.reload
      expect(de_account.bank_account_name).to            eq 'JaidaDickinson'
      expect(de_account.bank_account_number).to          eq 'FMRASPOE'
      expect(de_account.bank_routing_number).to          eq 'RLMGDKQR'
      expect(de_account.account_address).to              eq '4824 Terrance Center'
      expect(de_account.account_campaign_disclaimer).to  eq 'WADQPKOR'
      expect(de_account.account_committee_name).to       eq 'NikoBeahan'
      expect(de_account.account_city).to                 eq 'Lake Keven'
      expect(de_account.account_district_or_locality).to eq 'NFJQRDII'
      expect(de_account.account_recipient_kind).to       eq 'KMDBIJCH'
      expect(de_account.account_full_name).to            eq 'TerrellFritsch'
      expect(de_account.account_party).to                eq 'JYCEEANX'
      expect(de_account.account_state).to                eq 'NC'
      expect(de_account.account_zip).to                  eq '44892'
      expect(de_account.contact_address).to              eq '51714 McCullough Isle'
      expect(de_account.contact_city).to                 eq 'Lake Marilyne'
      expect(de_account.contact_email).to                eq 'furman.beer@schuppe.name'
      expect(de_account.contact_first_name).to           eq 'Macey'
      expect(de_account.contact_last_name).to            eq 'Hermiston'
      expect(de_account.contact_phone).to                eq '(373)852-0868 x583'
      expect(de_account.contact_state).to                eq 'MO'
      expect(de_account.show_employer_address).to        eq true
      expect(de_account.show_employer_name).to           eq false
      expect(de_account.show_occupation).to              eq true
      expect(de_account.contact_zip).to                  eq '17998-2838'
      expect(de_account.email).to                        eq 'laria_hudson@keelingemard.org'
      expect(de_account.contribution_limit).to           eq 5
      expect(de_account.uuid).to                         eq 'LXUNMJLV'
    end

    specify 'failure' do
      patch :update, id: de_account.id, de_account: params.merge(email: '')

      expect(response).to render_template :edit
      expect(de_account.bank_account_name).to_not eq 'JaidaDickinson'
    end
  end
end
