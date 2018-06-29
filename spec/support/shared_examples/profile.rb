shared_examples_for 'Profile' do
  let(:model_symbol) { described_class.to_s.underscore.to_sym }
  let!(:image_example) { File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')) }

  describe 'associations' do
    it { expect(subject).to have_many(:ownerships) }
    it { expect(subject).to have_many(:admin_ownerships) }
    it { expect(subject).to have_many(:editor_ownerships) }

    it { expect(subject).to have_many(:accounts).through(:ownerships) }
    it { expect(subject).to have_one(:account) }
    it { expect(subject).to belong_to(:owner) }
    it { expect(subject).to have_one :credit_card_holder }
    it { expect(subject).to have_many(:media).dependent(:destroy) }
    it { expect(subject).to belong_to :photo_medium }
    it { expect(subject).to belong_to :hero_unit_medium }
    it { expect(subject).to have_one(:de_account).dependent(:destroy) }
    it { expect(subject).to have_one(:domain) }
    it { expect(subject).to have_many(:donations).dependent(:destroy) }
    it { expect(subject).to have_many(:oauth_accounts).dependent(:destroy) }
    it { expect(subject).to have_many(:social_posts).dependent(:destroy) }
    it { expect(subject).to have_many(:domains).dependent(:delete_all) }
    it { expect(subject).to have_many(:events).dependent(:destroy) }
    it { expect(subject).to have_many(:press_releases).dependent(:destroy) }
    it { expect(subject).to have_many(:press_release_images).dependent(:destroy) }
    it { expect(subject).to have_many(:issue_categories).dependent(:destroy) }
    it { expect(subject).to have_many(:issues).dependent(:destroy) }
    it { expect(subject).to have_many(:questions).dependent(:destroy) }
    it { expect(subject).to have_many(:subscriptions) }
    it { expect(subject).to have_many(:users).through(:subscriptions) }
  end

  describe 'validations', :unstub_url_existence do
    it { expect(subject).to validate_inclusion_of(:state).in_array(US_STATES_ABBREVIATIONS) }
    it { expect(subject).to validate_inclusion_of(:contact_state).in_array(US_STATES_ABBREVIATIONS) }
    it { expect(subject).to allow_value(nil).for(:state) }
    it { expect(subject).to allow_value(nil).for(:contact_state) }
    it { expect(subject).to allow_value(nil).for(:contact_zip) }
    it { expect(subject).to allow_value('').for(:state) }
    it { expect(subject).to allow_value('').for(:contact_state) }
    it { expect(subject).to allow_value('').for(:contact_zip) }
    it { expect_to_validate_url_without_schema(:campaign_website) }
    it { expect_to_validate_phone_number(:phone) }
    it { expect_to_validate_zip_format(:contact_zip) }

    specify 'should build domain' do
      expect(subject.domain).to be_nil
      subject.valid?
      expect(subject.domain).not_to be_nil
    end
  end

  describe '#has_admin?' do
    let!(:admin)      { create :account, profile: profile }
    let!(:profile)    { create :candidate_profile }
    let!(:editor)     { create :account, profile: profile }
    let!(:ownership1) { create :ownership, profile: profile, account: admin }
    let!(:ownership2) { create :ownership, profile: profile, account: editor, type: 'EditorOwnership' }

    specify do
      expect(profile.has_admin?(admin)).to be_truthy
      expect(profile.has_admin?(editor)).to be_falsey
    end
  end

  describe '#shown_issue_categories' do
    let!(:profile)   { create model_symbol }
    let!(:category1) { create(:issue_category, profile: profile) }
    let!(:category2) { create(:issue_category, profile: nil) }
    let!(:category3) { create(:issue_category, profile: nil) }
    let!(:category4) { create(:issue_category, profile: profile) }
    let!(:issue1)    { create(:issue, issue_category: category1, profile: profile) }
    let!(:issue2)    { create(:issue, issue_category: category2, profile: profile) }
    let!(:issue3)    { create(:issue, issue_category: category3, profile: create(model_symbol)) }

    specify do
      expect(profile.shown_issue_categories.to_a.sort).to eq [category1, category2].sort
    end
  end

  describe '#allowed_background_images' do
    let!(:profile) { create model_symbol }
    let!(:other_profile) { create model_symbol }

    let!(:image_with_profile) { create(:medium, profile: profile) }
    let!(:video_with_profile) { create(:medium, :video, profile: profile) }

    let!(:image_with_other_profile) { create(:medium, profile: other_profile) }
    let!(:video_with_other_profile) { create(:medium, :video, profile: other_profile) }

    let!(:image_without_profile) { create(:medium, profile: nil) }
    let!(:video_without_profile) { create(:medium, :video, profile: nil) }

    specify do
      profile.allowed_background_images.tap do |images|
        expect(images.count).to eq 2
        expect(images).to include image_with_profile, image_without_profile
      end
    end
  end

  describe '#media_stream_items' do
    let!(:profile) { create model_symbol }
    let!(:medium1) { create(:medium, profile: profile) }
    let!(:medium2) { create(:medium, profile: profile) }

    it 'should return media by position' do
      Medium.update_positions([medium2.id, medium1.id])

      expect(profile.media_stream_items).to eq [medium2, medium1]
    end

    it 'should return empty array when there are no items' do
      expect(profile.media_stream_items).to eq []
    end
  end

  describe '#city_and_state' do
    it { expect(build(model_symbol, city: 'City', state: 'CA').city_and_state).to eq 'City, CA' }
    it { expect(build(model_symbol, city: 'City', state: nil).city_and_state).to eq 'City' }
    it { expect(build(model_symbol, city: 'City', state: '').city_and_state).to eq 'City' }
    it { expect(build(model_symbol, city: nil, state: 'CA').city_and_state).to eq 'CA' }
    it { expect(build(model_symbol, city: '', state: 'CA').city_and_state).to eq 'CA' }
  end

  describe '#premium?' do
    let(:profile) do
      build(model_symbol, credit_card_holder: credit_card_holder, premium_by_default: premium_by_default)
    end

    context 'premium_by_default is true' do
      let(:premium_by_default) { true }
      let(:credit_card_holder) { nil }

      specify { expect(profile).to be_premium }
    end

    context 'premium_by_default is false' do
      let(:premium_by_default) { false }

      context 'without credit card holder' do
        let(:credit_card_holder) { nil }
        specify { expect(profile).to_not be_premium }
      end

      context 'with credit card holder' do
        let(:credit_card_holder) { build(:credit_card_holder, token: token) }

        context 'with blank token' do
          let(:token) { ' ' }
          specify { expect(profile).to_not be_premium }
        end

        context 'with token' do
          let(:token) { 'token' }
          specify { expect(profile).to be_premium }
        end
      end
    end
  end

  describe '#photo_url' do
    let!(:profile) do
      create(model_symbol, photo: File.open(Rails.root.join('spec', 'fixtures', 'image1.jpg')))
    end

    before { allow_any_instance_of(described_class).to receive(:updated_at).and_return(1) }

    it 'should add version timestamp to url' do
      expect(profile.reload.photo_url).to end_with '?version=1'
      expect(profile.reload.photo_url(:thumb)).to end_with '?version=1'
    end
  end

  describe 'observers' do
    specify 'before_validation: add_schema_to_campaign_website' do
      profile = create(model_symbol, campaign_website: 'google.com')
      expect(profile.campaign_website).to eq 'http://google.com'
    end

    describe 'after_create:generate_subdomain' do
      let!(:profile1) { create(model_symbol, name: 'Carl Johnson') }
      let!(:profile2) { build(model_symbol, account: nil, name: 'Carl Johnson') }

      specify 'creating new domain for new profile' do
        profile2.save

        expect(profile1.domain.name).to eq 'carl-johnson'
        expect(profile2.domain.name).to start_with 'carl-johnson-'
      end
    end
  end

  describe '#can_accept_donations?' do
    context 'all data is valid' do
      let!(:profile) { create(model_symbol, donations_on: true) }
      let!(:de_account) { create(:de_account, is_active_on_de: true, profile: profile) }

      specify { expect(profile.can_accept_donations?).to be_truthy }
    end

    describe 'method should return false' do
      after { expect(profile.can_acceept_donations?).to be_falsey }

      context 'DE account inactive' do
        let!(:profile) { create(model_symbol, donations_on: true) }
        let!(:de_account) { create(:de_account, is_active_on_de: false, profile: profile) }
      end

      context 'no DE account' do
        let!(:profile) { create(model_symbol, donations_on: true) }
      end

      context 'donations OFF' do
        let!(:account) { create(model_symbol, donations_on: false) }
        let!(:de_account) { create(:de_account, is_active_on_de: true, profile: profile) }
      end
    end
  end

  describe '#url_for' do
    let!(:profile) { create model_symbol }

    let!(:twitter) do
      create :oauth_account, provider: 'twitter',
                             url:      'https://twitter.com/user',
                             profile: profile
    end

    let!(:facebook) do
      create :oauth_account, provider: 'facebook',
                             url:       'https://facebook.com/user',
                             profile: profile
    end

    specify do
      expect(profile.url_for(:twitter)).to  eq twitter.url
      expect(profile.url_for(:facebook)).to eq facebook.url
    end
  end

  describe '#facebook_account' do
    let!(:profile) { create model_symbol }
    let!(:facebook_account) { create :oauth_account, provider: 'facebook', profile: profile }

    it 'should get facebook account' do
      expect(profile.facebook_account).to eq facebook_account
    end
  end

  describe '#facebook_account_active?' do
    let!(:profile) { create model_symbol }

    specify 'without account' do
      expect(profile.facebook_account_active?).to be_falsey
    end

    context 'with inactive account' do
      let!(:oauth_account) { create :oauth_account, :facebook, aasm_state: 'inactive', profile: profile }

      specify do
        expect(profile.facebook_account_active?).to be_falsey
      end
    end

    context 'with active account' do
      let!(:oauth_account) { create :oauth_account, :facebook, aasm_state: 'active', profile: profile }

      specify do
        expect(profile.facebook_account_active?).to be_truthy
      end
    end
  end

  describe '#twitter_account_active?' do
    let!(:profile) { create model_symbol }

    specify 'without account' do
      expect(profile.twitter_account_active?).to be_falsey
    end

    context 'with inactive account' do
      let!(:oauth_account) { create :oauth_account, :twitter, aasm_state: 'inactive', profile: profile }

      specify do
        expect(profile.twitter_account_active?).to be_falsey
      end
    end

    context 'with active account' do
      let!(:oauth_account) { create :oauth_account, :twitter, aasm_state: 'active', profile: profile }

      specify do
        expect(profile.twitter_account_active?).to be_truthy
      end
    end
  end

  describe '#invite_editor' do
    let!(:profile) { create model_symbol }

    context 'find and invite' do
      let!(:account) { create(:account) }
      let(:email) { account.email }

      specify do
        expect {
          expect(profile.invite_editor(email).id).to eq account.id
        }.to change(Account, :count).by (0)

        profile.ownerships.last.tap do |ownership|
          expect(ownership.account).to eq account
          expect(ownership.type).to eq 'EditorOwnership'
        end
      end
    end

    context 'create and invite' do
      let(:email) { 'some-new@mail.com' }

      specify do
        expect {
          expect(profile.invite_editor(email).email).to eq email
        }.to change(Account, :count).by (1)

        profile.ownerships.last.tap do |ownership|
          expect(ownership.account.email).to eq email
          expect(ownership.type).to eq 'EditorOwnership'
        end
      end
    end

    specify 'with blank email' do
      expect {
        expect(profile.invite_editor(nil).errors[:email]).to eq ["can't be blank"]
      }.not_to change(Account, :count)
    end
  end

  describe '#twitter_account' do
    let!(:profile) { create model_symbol }
    let!(:twitter_account) { create :oauth_account, provider: 'twitter', profile: profile }

    it 'should get twitter account' do
      expect(profile.twitter_account).to eq twitter_account
    end
  end

  describe 'display social buttons' do
    describe '#show_facebook_buttons?' do
      let(:profile) { create model_symbol, facebook_on: facebook_on }

      context 'without account' do
        context 'facebook_on is true' do
          let(:facebook_on) { true }
          specify { expect(profile.show_facebook_buttons?).to be_falsey }
        end

        context 'facebook_on is false' do
          let(:facebook_on) { false }
          specify { expect(profile.show_facebook_buttons?).to be_falsey }
        end
      end

      context 'with account' do
        before { allow_any_instance_of(OauthAccount).to receive(:show_buttons) }

        let!(:oauth_account) do
          create(:oauth_account, profile: profile, provider: 'facebook', aasm_state: state)
        end

        context 'with active account' do
          let(:state) { 'active' }

          context 'facebook_on is true' do
            let(:facebook_on) { true }
            specify { expect(profile.show_facebook_buttons?).to be_truthy }
          end

          context 'facebook_on is false' do
            let(:facebook_on) { false }
            specify { expect(profile.show_facebook_buttons?).to be_falsey }
          end
        end

        context 'with inactive account' do
          let(:state) { 'inactive' }

          context 'facebook_on is true' do
            let(:facebook_on) { true }
            specify { expect(profile.show_facebook_buttons?).to be_falsey }
          end

          context 'facebook_on is false' do
            let(:facebook_on) { false }
            specify { expect(profile.show_facebook_buttons?).to be_falsey }
          end
        end
      end
    end

    describe '#show_twitter_buttons?' do
      let(:profile) { create model_symbol, twitter_on: twitter_on }

      context 'without account' do
        context 'twitter_on is true' do
          let(:twitter_on) { true }
          specify { expect(profile.show_twitter_buttons?).to be_falsey }
        end

        context 'twitter_on is false' do
          let(:twitter_on) { false }
          specify { expect(profile.show_twitter_buttons?).to be_falsey }
        end
      end

      context 'with account' do
        before { allow_any_instance_of(OauthAccount).to receive(:show_buttons) }

        let!(:oauth_account) do
          create(:oauth_account, profile: profile, provider: 'twitter', aasm_state: state)
        end

        context 'with active account' do
          let(:state) { 'active' }

          context 'twitter_on is true' do
            let(:twitter_on) { true }
            specify { expect(profile.show_twitter_buttons?).to be_truthy }
          end

          context 'twitter_on is false' do
            let(:twitter_on) { false }
            specify { expect(profile.show_twitter_buttons?).to be_falsey }
          end
        end

        context 'with inactive account' do
          let(:state) { 'inactive' }

          context 'twitter_on is true' do
            let(:twitter_on) { true }
            specify { expect(profile.show_twitter_buttons?).to be_falsey }
          end

          context 'twitter_on is false' do
            let(:twitter_on) { false }
            specify { expect(profile.show_twitter_buttons?).to be_falsey }
          end
        end
      end
    end
  end

  describe 'register_to_vote_url' do
    before { subject.register_to_vote_url = register_to_vote_url }

    context 'register_to_vote_url_url presents' do
      let(:register_to_vote_url) { 'https://google.com' }
      specify { expect(subject.register_to_vote_url).to eq register_to_vote_url }
    end

    context 'register_to_vote_url_url is blank' do
      let(:register_to_vote_url) { '' }
      specify { expect(subject.register_to_vote_url).to eq Profile::REGISTER_TO_VOTE_DEFAULT_URL }
    end
  end
end
