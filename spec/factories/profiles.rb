FactoryGirl.define do
  factory :profile do
    office 'Governor'
    tagline 'Test Slogan'
    phone '730-233-3238'
    city 'Los Angeles'
    state 'CA'
    party_affiliation 'Democrat'
    district 'who knows'
    address_1 '84, Main st.'
    address_2 '85, Main st.'
    biography 'Test biography - about the author.'
    contact_zip '12345'
    contact_state 'CA'
    contact_city 'Los Angeles'
    campaign_website 'http://www.google.com'
    photo_cropping_width 130
    photo_cropping_offset_x 50
    photo_cropping_offset_y 30
    background_image_cropping_width 130
    background_image_cropping_offset_x 50
    background_image_cropping_offset_y 30

    trait :with_social_links do
      facebook_on  true
      twitter_on   true
    end

    trait :without_domain do
      before (:create) { Profile.skip_callback(:create, :before, :generate_subdomain) }
      after (:create)  { Profile.set_callback(:create, :before, :generate_subdomain) }
    end

    trait(:free)
    trait(:premium) { credit_card_holder }
  end

  factory :candidate_profile, parent: :profile, class: 'CandidateProfile' do
    first_name 'Bob'
    last_name 'Sinclar'
  end

  factory :organization_profile, parent: :profile, class: 'OrganizationProfile' do
    name 'Organization Name'
  end
end
