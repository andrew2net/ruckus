# Oauth account model
class OauthAccount < ActiveRecord::Base
  PROVIDERS = %w[twitter facebook].freeze

  include AASM

  belongs_to :profile
  has_many :campaing_pages, dependent: :destroy
  accepts_nested_attributes_for :campaing_pages

  validates :provider, presence: true, uniqueness: { scope: :profile_id }, inclusion: PROVIDERS
  validates :uid,      presence: true, uniqueness: { scope: [:profile_id, :provider] }
  validates :url,      presence: true

  scope :by_provider, ->(provider) { where(provider: provider) }

  after_create :show_buttons

  aasm do
    state :linked, initial: true, after_enter: :fb_load_pages
    state :active, after_enter: :show_buttons
    state :inactive

    event :link do
      transitions to: :linked
    end

    event :activate do
      transitions to: :active
    end

    event :deactivate do
      transitions to: :inactive
    end
  end

  def fb_load_pages
    return unless provider == 'facebook'
    graph = Koala::Facebook::API.new oauth_token
    cp_ids = graph.get_connections('me', 'accounts').map do |p|
      campaing_pages.find_or_create_by page_id: p['id'] do |cp|
        cp.access_token = p['access_token']
        cp.name         = p['name']
      end
      p['id']
    end
    campaing_pages.where.not(page_id: cp_ids).destroy_all
  end

  private

  def show_buttons
    profile.update_attribute("#{provider}_on", true) if profile.present?
  end
end
