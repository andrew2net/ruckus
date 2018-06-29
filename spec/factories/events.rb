# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    association :profile, factory: :candidate_profile

    sequence(:title) { |n| "Some title #{n}" }
    start_time 5.minutes.from_now
    end_time 2.years.from_now
    address 'Lincoln st'
    city 'New York City'
    state 'NY'
    zip '10001'
    description 'Great Concert'
    time_zone 'EDT'
    show_start_time false
  end
end
