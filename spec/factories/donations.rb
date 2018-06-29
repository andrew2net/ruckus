# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :donation do
    association :profile, factory: :candidate_profile
    credit_card

    donor_first_name 'John'
    donor_middle_name 'Jr'
    donor_last_name 'Smit'
    donor_email 'johnsmith@gmail.com'
    donor_phone '112-223-3344'
    donor_address_1 'my street 1'
    donor_address_2 'my street 2'
    donor_city 'New York City'
    donor_state 'NY'
    donor_zip '11222'
    employer_name 'Op Inc.'
    employer_occupation 'Manager'
    employer_address 'the other street'
    employer_city 'Los Angeles'
    employer_state 'CA'
    employer_zip '13342'
    amount 10
    transaction_guid SecureRandom.uuid
    transaction_uri ['https://de-test.com/donations/', SecureRandom.uuid, '.json'].join
    agree_with_terms '1'
  end
end
