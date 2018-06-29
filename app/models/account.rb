class Account < ActiveRecord::Base
  include Chartable
  acts_as_paranoid

  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable, :omniauthable

  has_many :ownerships
  has_many :admin_ownerships
  has_many :editor_ownerships

  has_many :profiles, through: :ownerships, dependent: :destroy
  has_many :candidate_profiles, through: :ownerships, dependent: :destroy     # I don't even think I need this
  has_many :organization_profiles, through: :ownerships, dependent: :destroy     # I don't even think I need this

  belongs_to :profile
  belongs_to :candidate_profile, foreign_key: 'profile_id'
  belongs_to :organization_profile, foreign_key: 'profile_id'

  has_many :logins, dependent: :destroy, class_name: 'Request', as: :requestable

  accepts_nested_attributes_for :candidate_profile
  accepts_nested_attributes_for :organization_profile

  scope :with_first, -> (id) { order("accounts.id = #{id} DESC") }
  scope :admins_first, -> { order('ownerships.type ASC') }
  scope :by_id, -> { order(:id) }

  scope :inactive, -> do
    joins(:profile).where('profiles.id NOT IN (SELECT credit_card_holders.profile_id FROM credit_card_holders
      WHERE profile_id IS NOT NULL) AND profiles.premium_by_default = false')
  end

  scope :active, -> do
    where('accounts.deleted_at IS NULL').joins(:profile).where('profiles.id IN (SELECT credit_card_holders.profile_id
      FROM credit_card_holders WHERE credit_card_holders.token IS NOT NULL AND profile_id IS NOT NULL)
      OR profiles.premium_by_default = true')
  end

  def update(params)
    # todo: ask for a password when account changes his email
    # (it's a security issue, we had it by default  but we turned it off here by client's request)
    if params[:password].present?
      super
    else
      update_without_password(params)
    end
  end

  def active_for_authentication?
    super && !deleted?
  end

  def inactive_message
    deleted? ? :deleted : super
  end
end
