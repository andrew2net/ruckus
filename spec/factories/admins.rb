# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin do
    email
    password "secret123"
    password_confirmation "secret123"
  end
end
