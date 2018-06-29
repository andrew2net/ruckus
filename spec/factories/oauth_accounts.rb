# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :oauth_account do
    association :profile, factory: :candidate_profile

    sequence(:uid) { |n| "uid#{n}" }
    provider 'twitter'
    url 'https://twitter.com/WillFerrell'

    trait :twitter do
    end

    trait :facebook do
      provider 'facebook'
      url 'https://facebook.com/WillFerrell'
    end
  end
end
