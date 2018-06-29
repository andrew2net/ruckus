class AddFacebookUrlAndTwitterUrlToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :facebook_url, :string
    add_column :profiles, :twitter_url,  :string
  end
end
