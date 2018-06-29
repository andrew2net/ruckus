FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "some_mail#{n}@mail.com" }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name)  { |n| "Last#{n}" }
  end
end
