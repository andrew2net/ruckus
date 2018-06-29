FactoryGirl.define do
  factory :coupon do
    sequence(:code) { |n| "somecode#{n}" }
    discount 1.3
  end
end
