# Post on campaing page
class CampaingPagePost < ActiveRecord::Base
  before_destroy :remove_from_facebook, prepend: true

  belongs_to :social_post, inverse_of: :campaing_page_posts
  belongs_to :campaing_page, inverse_of: :campaing_page_posts

  private

  def remove_from_facebook
    conn = Koala::Facebook::API.new(campaing_page.try(:access_token))
    conn.delete_object(remote_id)['success']
  end
end
