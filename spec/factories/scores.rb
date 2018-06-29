FactoryGirl.define do
  factory :score do
    scorable_type 'Issue'
    scorable_id { create(:issue).id }
    ip Faker::Internet.ip_v4_address
  end
end
