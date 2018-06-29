# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :medium do
    image File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg'))

    trait :video do
      image nil
      video_url 'https://www.youtube.com/watch?v=6CuTsLTrN9E'
    end
  end
end
