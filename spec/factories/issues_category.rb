FactoryGirl.define do
  factory :issue_category do
    association :profile, factory: :candidate_profile
    sequence(:name) { |n| "Issue category name #{n}" }
  end
end
