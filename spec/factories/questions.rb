FactoryGirl.define do
  factory :question do
    user
    association :profile, factory: :candidate_profile

    sequence(:text) { |n| "Some question #{n}" }
  end
end
