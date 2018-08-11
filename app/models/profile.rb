class Profile < ActiveRecord::Base
  REGISTER_TO_VOTE_DEFAULT_URL = ruckus? ? 'http://rockthevote.com/register-to-vote/' : 'http://register.gop/'

  include Cacheable

  has_many :ownerships
  has_many :admin_ownerships
  has_many :editor_ownerships

  has_many :accounts, through: :ownerships
  has_one :account
  has_one :credit_card_holder, dependent: :destroy
  belongs_to :owner, class_name: 'Account'

  belongs_to :photo_medium,            class_name: 'Medium'
  belongs_to :hero_unit_medium,        class_name: 'Medium'
  belongs_to :background_image_medium, class_name: 'Medium'
  has_one :de_account, dependent: :destroy
  has_one :domain, -> { where(internal: true) }
  has_many :donations,            dependent: :destroy
  has_many :domains,              dependent: :delete_all
  has_many :events,               dependent: :destroy
  has_many :press_releases,       dependent: :destroy
  has_many :press_release_images, dependent: :destroy
  has_many :media,                dependent: :destroy
  has_many :issue_categories,     dependent: :destroy
  has_many :issues,               dependent: :destroy

  has_many :oauth_accounts,           dependent: :destroy
  has_many :social_posts,             dependent: :destroy

  has_many :questions,                dependent: :destroy
  has_many :subscriptions,            dependent: :destroy
  has_many :users, through: :subscriptions

  validates :state, inclusion: { in: US_STATES_ABBREVIATIONS }, allow_blank: true, allow_nil: true
  validates :contact_state, inclusion: { in: US_STATES_ABBREVIATIONS }, allow_blank: true, allow_nil: true
  validates :campaign_website, url_format: true
  validates :domain, presence: true
  validates :phone, phone_number: true
  validates :contact_zip, zip_format: true

  before_validation :check_campaign_website
  before_validation :generate_subdomain

  mount_uploader :background_image, BackgroundImageUploader
  mount_uploader :hero_unit, HeroUnitUploader

  def has_admin?(account)
    admin_ownerships.where(account_id: account.id).exists?
  end

  def premium?
    premium_by_default? || (credit_card_holder.present? && credit_card_holder.token.present?)
  end

  def allowed_background_images
    @allowed_background_images ||= Medium.only_images.where(profile_id: [id, nil])
  end

  def city_and_state
    [city, state].select(&:present?).join(', ')
  end

  def can_accept_donations?
    donations_on? && de_account.present? && de_account.is_active_on_de?
  end

  def sum_donations
    donations.sum(:amount)
  end

  def allowed_categories
    IssueCategory.where(profile_id: [id, nil]).order(:created_at)
  end

  def shown_issue_categories
    allowed_categories.where(id: issues.pluck(:issue_category_id))
  end

  def media_stream_items
    @media_stream_items ||= media.where.not(position: nil).by_position
  end

  # socials
  def show_facebook_buttons?
    facebook_account.present? && facebook_on? && facebook_account_active?
  end

  def show_twitter_buttons?
    twitter_account.present? && twitter_on? && twitter_account_active?
  end

  def facebook_account
    oauth_account('facebook')
  end

  def facebook_account_active?
    oauth_account_active?('facebook')
  end

  def facebook_account_linked?
    account = oauth_account 'facebook'
    account.present? && (account.linked? || account.active?)
  end

  def twitter_account
    oauth_account('twitter')
  end

  def twitter_account_active?
    oauth_account_active?('twitter')
  end

  def twitter_url
    twitter_account.url
  end

  def twitter_id
    twitter_url.split('/').last
  end

  def facebook_connection
    @facebook ||= Koala::Facebook::API.new(facebook_account.try(:oauth_token))
  end

  def twitter_connection
    @twitter ||= Twitter::REST::Client.new do |config|
      config.consumer_key = OAUTH_PROVIDERS['twitter']['client_id']
      config.consumer_secret = OAUTH_PROVIDERS['twitter']['client_secret']
      config.access_token = twitter_account.try(:oauth_token)
      config.access_token_secret = twitter_account.try(:oauth_secret)
    end
  end

  def invite_editor(email)
    if email.present?
      @account = Account.with_deleted.find_by_email(email)

      if @account.present? && @account.profile_ids.include?(id)
        @account.errors[:email] << 'alredy exists'
      else
        @account = Account.with_deleted.invite!(email: email)

        if @account.present? && @account.valid? && !(@account.profiles.include?(self))
          @account.profiles << self
          @account.update_column :profile_id, id if @account.profile_id.blank?
          @account.ownerships.where(profile_id: id).update_all(type: 'EditorOwnership')
        end
      end
    else
      @account = Account.new
      @account.errors[:email] << "can't be blank"
    end

    @account
  end

  def url_for(provider)
    @url_for ||= {}
    provider ||= provider.to_sym

    unless @url_for.has_key?(provider)
      @url_for[provider] = oauth_accounts.by_provider(provider.to_s).first.try(:url)
    end

    @url_for[provider]
  end

  def register_to_vote_url
    super.present? ? super : REGISTER_TO_VOTE_DEFAULT_URL
  end

  private

  def photo_url_with_version(version = nil)
    "#{photo.url(version)}?version=#{updated_at.to_i}"
  end

  def check_campaign_website
    if campaign_website.present? && campaign_website.exclude?('://')
      self.campaign_website = "http://#{campaign_website}"
    end
  end

  def generate_subdomain
    if domains.blank? && domain.blank?
      build_domain(new_account: true)
      domain.generate_random_name
    end
  end

  # socials
  def oauth_account(provider)
    cached_method("#{provider}_account") { oauth_accounts.by_provider(provider).first }
  end

  def oauth_account_active?(provider)
    account = oauth_account(provider)
    account.present? && account.active?
  end
end
