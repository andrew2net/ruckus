FactoryGirl.define do
  factory :credit_card_holder do
    credit_card

    first_name 'John'
    last_name 'Doe'
    state 'CA'
    city 'Louisiana'
    zip '12345'
    address 'Street'
    token 'token'
  end
end
