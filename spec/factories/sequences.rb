FactoryGirl.define do
  sequence(:email)     { |n| "email#{n}@factory.com" }
  sequence(:subdomain) { |n| "subdomain#{n}" }
end
