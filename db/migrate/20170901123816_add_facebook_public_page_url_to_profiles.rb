class AddFacebookPublicPageUrlToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :facebook_public_page_url, :string
  end
end
