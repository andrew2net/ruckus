# clear DB
ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.tables.each do |table|
  next if table == 'schema_migrations'
  ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
end

# Superadmin
FactoryGirl.create :admin, email: 'admin@ruck.us', password: 'secret123!', password_confirmation: 'secret123!'

# Issue Categories
category_names = %w(Education Economy Energy Environment Taxes Healthcare Immigration Transportation
                    Political\ Reform Constitutional\ Rights Public\ Safety Foreign\ Policy Veterans\ Affairs National\ Security)
category_names.each { |name| FactoryGirl.create :issue_category, name: name, profile: nil }

# Global Backgrounds
file_paths = Dir.glob(File.join(Rails.root, 'spec', 'fixtures', 'backgrounds', '*.jpg'))
file_paths.collect { |path| FactoryGirl.create(:medium, image: File.open(path)) }

# Coupons
2.times { FactoryGirl.create :coupon, discount: rand(0.0..20.0) }
coupon_ids = Coupon.pluck(:id) << nil

# Accounts
%w(ferrell@example.com account1@example.com account2@example.com account3@exaple.com).each do |email|
  FactoryGirl.create :account, email: email, password: 'password', password_confirmation: 'password'
end

# Profiles
Account.all.each do |account|
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  office = Faker::Company.position

  # create premium profile, for which he's admin
  premium_profile = FactoryGirl.create :candidate_profile,
    account: account,
    first_name: first_name,
    last_name: last_name,
    office: office,
    tagline: Faker::Company.bs,
    phone: Faker::PhoneNumber.short_phone_number,
    city: Faker::AddressUS.city,
    state: Faker::AddressUS.state_abbr,
    address_1: Faker::Address.street_address,
    party_affiliation: %w(Republican Democrat).sample,
    district: "#{first_name}'s District",
    biography: "My name is #{name}. #{Faker::Lorem.sentences.join(' ') * 10}",
    campaign_disclaimer: "#{first_name} #{last_name}"

  FactoryGirl.create :credit_card_holder, profile: premium_profile, coupon_id: coupon_ids.sample

  basic_profile = FactoryGirl.create :candidate_profile,
    account: account,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    office: Faker::Company.position,
    tagline: Faker::Company.bs,
    phone: Faker::PhoneNumber.short_phone_number,
    city: Faker::AddressUS.city,
    state: Faker::AddressUS.state_abbr,
    address_1: Faker::Address.street_address,
    party_affiliation: %w(Republican Democrat).sample,
    district: "#{first_name}'s District",
    biography: "My name is #{name}. #{Faker::Lorem.sentences.join(' ') * 10}",
    campaign_disclaimer: "#{first_name} #{last_name}"

  # Editors for PremiumProfile
  editor = FactoryGirl.create :account, email: "editor#{rand(0..99999)}@example.com"
  invitee = FactoryGirl.create :account, :just_invited, email: "invitee#{rand(0..99999)}@example.com"

  premium_profile.accounts << editor
  premium_profile.accounts << invitee

  premium_profile.ownerships.where(account_id: [editor, invitee]).update_all(type: 'EditorOwnership')

  # CurrentlyEditing
  Account.where(id: [account, editor, invitee]).update_all profile_id: premium_profile.id

  # Profile data
  [premium_profile, basic_profile].each do |profile|
    # Create Media
    photo = FactoryGirl.create :medium, profile: profile, image: File.open(Rails.root.join('spec', 'fixtures', 'photo.jpg'))
    background = FactoryGirl.create :medium, profile: profile, image: File.open(Rails.root.join('spec', 'fixtures', 'background.jpg'))
    hero_unit = FactoryGirl.create :medium, profile: profile, image: File.open(Rails.root.join('spec', 'fixtures', 'background.jpg'))

    # Set media
    Media::ProfileUpdater::Photo.new(profile, profile: { photo_medium_id: photo.id }).process
    Media::ProfileUpdater::BackgroundImage.new(profile, profile: { background_image_medium_id: background.id }).process
    Media::ProfileUpdater::HeroUnit.new(profile, profile: { hero_unit_medium_id: hero_unit.id }).process

    # Press
    5.times do
      release = FactoryGirl.build :press_release, profile: profile
      release.save(validate: false)
    end

    # Events
    [[2014, 02, 01],
     [2012, 03, 03],
     [2011, 05, 04],
     [2011, 05, 07],
     [Date.today.year, Date.today.month, Date.today.day],
     [Date.today.year + 2, Date.today.month, Date.today.day],
     [Date.today.year, Date.today.month, 28]
    ].each do |arr|
      start_time = Time.new(arr[0], arr[1], arr[2], 21, 48, 18)
      end_time = start_time + rand(5..10).hours
      event = FactoryGirl.build :event, profile: profile, start_time: start_time, end_time: end_time
      event.save validate: false
    end

    # Issues
    issue_categories = (1..4).to_a.collect { FactoryGirl.create :issue_category, profile: profile }
    10.times { FactoryGirl.create :issue, profile: profile, issue_category: issue_categories.sample }

    # Media Stream
    media_paths = Dir.glob(File.join(Rails.root, 'spec', 'fixtures', 'image?.jpg'))
    images = media_paths.collect { |path| File.open(path) }
    media = images.collect{ |image| FactoryGirl.create :medium, profile: profile, image: image }
    Medium.update_positions(media.map(&:id))

    # Users
    5.times do
      user = FactoryGirl.create :user, first_name:  Faker::Name.first_name,
                                       last_name:  Faker::Name.last_name,
                                       email: Faker::Internet.email
      profile.users << user
    end

    # DE account
    FactoryGirl.create :de_account, profile: profile

    # Questions
    5.times do
      FactoryGirl.create :question, profile: profile,
                                    text: Faker::Lorem.sentences.join(' '),
                                    user: User.first
    end

    # Donations
    5.times do
      donation = FactoryGirl.build :donation, profile: profile,
                                             donor_first_name: Faker::Name.first_name,
                                             donor_middle_name: nil,
                                             donor_last_name: Faker::Name.last_name,
                                             donor_email: Faker::Internet.email,
                                             donor_phone: Faker::PhoneNumber.phone_number,
                                             donor_address_1: Faker::Address.street_address,
                                             donor_address_2: Faker::Address.street_address,
                                             donor_city: Faker::AddressUS.city,
                                             donor_state: Faker::AddressUS.state_abbr,
                                             donor_zip: Faker::AddressUS.zip_code,
                                             employer_name: Faker::Company.name,
                                             employer_occupation: Faker::Job.title,
                                             employer_address: Faker::Address.street_address,
                                             employer_city: Faker::AddressUS.city,
                                             employer_state: Faker::AddressUS.state_abbr,
                                             employer_zip: Faker::AddressUS.zip_code,
                                             amount: rand(profile.de_account.donation_amounts),
                                             agree_with_terms: '1',
                                             credit_card_attributes: { number: '4111111111111111',
                                                                       cvv:    '123',
                                                                       month:  '12',
                                                                       year:   '2016' }
      donation.save validate: false
    end
  end
end

# Pages
%w(faq terms contact how-to-update-domain).each { |name| Page.create name: name }
