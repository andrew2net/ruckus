# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :support_message do |f|
    f.name 'Bob'
    f.email 'bob@gmail.com'
    f.subject 'Message Subject 1'
    f.message 'Test Message'
  end
end
