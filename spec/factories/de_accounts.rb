# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :de_account do
    association :profile, factory: :candidate_profile

    email                            'email@example.com'
    password                         'password21'
    password_confirmation            'password21'
    account_full_name                'John Johnson'
    account_committee_name           'Party'
    account_committee_id             '12345678'
    account_address                  'Some str'
    account_city                     'New York City'
    account_state                    'NY'
    account_zip                      '12345'
    account_recipient_kind           'local_account'
    account_district_or_locality     '123'
    account_campaign_disclaimer      'Hello World'
    account_party                    'Bob has a party'
    contribution_limit               2500
    show_employer_name               true
    show_employer_address            true
    show_occupation                  true
    bank_account_name                'Bank Account'
    bank_routing_number              '12345678'
    bank_account_number              '12345678'
    bank_account_number_confirmation '12345678'
    contact_email                    'other_email@example.com'
    contact_phone                    '234-567-8907'
    contact_first_name               'John'
    contact_last_name                'Smith'
    contact_address                  'Street'
    contact_city                     'Austin'
    contact_state                    'TX'
    contact_zip                      '34343'
    uuid                             nil
    terms                            '1'
    agreements                       ['agreement 1', 'agreement 2']
    billing_name                     'Bob Smith'
    billing_address                  'some address'
    billing_city                     'city'
    billing_zipcode                  '12345'
    billing_state                    'CO'

    trait :without_timestamps do
      created_at nil
      updated_at nil
    end
  end
end
