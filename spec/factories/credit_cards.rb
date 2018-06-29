# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :credit_card do
    number '4111111111111111'
    cvv '123'
    month '02'
    year (Time.current + 2.years).year.to_s

    last_four '1111'
  end
end
