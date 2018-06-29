# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_release do
    association :profile, factory: :candidate_profile

    sequence(:title) { |n| "Texas American Federation of Teachers #{n}" }
    sequence(:url)   { |n| "http://somelink#{n}.com" }
  end
end
