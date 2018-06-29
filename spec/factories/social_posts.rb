# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :social_post do
    association :profile, factory: :candidate_profile

    provider ['facebook']
    message 'Hello World'
    facebook_remote_id '12345678765432'
    twitter_remote_id '12345678765432'
  end
end
