FactoryGirl.define do
  factory :issue do
    issue_category
    profile_id { |issue| issue.try(:issue_category).try(:profile_id) }

    sequence(:title)       { |n| "Issue title #{n}" }
    sequence(:description) { |n| "Issue description #{n}" }
  end
end
