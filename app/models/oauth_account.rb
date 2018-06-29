class OauthAccount < ActiveRecord::Base
  PROVIDERS = %w(twitter facebook)
  include AASM

  belongs_to :profile

  validates :provider, presence: true, uniqueness: { scope: :profile_id }, inclusion: PROVIDERS
  validates :uid,      presence: true, uniqueness: { scope: [:profile_id, :provider] }
  validates :url,      presence: true

  scope :by_provider, -> (provider) { where(provider: provider) }

  after_create :show_buttons

  aasm do
    state :active, initial: true, after_enter: :show_buttons
    state :inactive

    event :activate do
      transitions to: :active
    end

    event :deactivate do
      transitions to: :inactive
    end
  end

  private

  def show_buttons
    profile.update_attribute("#{provider}_on", true) if profile.present?
  end
end
