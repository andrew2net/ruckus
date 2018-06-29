# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_release_image do
    association :profile, factory: :candidate_profile

    sequence(:press_release_url) { |n| "http://press.release.url#{n}.com" }
    image File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg'))
  end
end
