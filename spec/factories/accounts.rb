# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account do
    profile
    email
    password 'secret123'
    password_confirmation 'secret123'

    invitation_accepted_at Time.now
    invitation_created_at Time.now
    invitation_sent_at Time.now

    trait :just_invited do
      invitation_accepted_at nil
      invitation_created_at nil
      invitation_sent_at nil
    end

    trait :without_timestamps do
      created_at nil
      current_sign_in_at nil
      deleted_at nil
      last_sign_in_at nil
      remember_created_at nil
      reset_password_sent_at nil
      updated_at nil
    end
  end
end
