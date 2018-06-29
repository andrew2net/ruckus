FactoryGirl.define do
  factory :domain do
    sequence(:name) { |n| "sub#{n}" }

    before :create do |domain, evaluator|
      if !evaluator.profile && !evaluator.profile_id
        params = [:create, :after, :generate_subdomain]
        Profile.skip_callback(*params)
        domain.profile = create(:candidate_profile)
        Profile.set_callback(*params)
      end
    end
  end
end
