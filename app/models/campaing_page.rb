class CampaingPage < ActiveRecord::Base
  belongs_to :oauth_account
  has_many :campaing_page_posts, inverse_of: :campaing_page

  validates :page_id, presence: true, uniqueness: { scope: :oauth_account_id }
  validates :name, presence: true
  validates :access_token, presence: true

  scope :publishing, -> { where(publishing_on: true) }
end
