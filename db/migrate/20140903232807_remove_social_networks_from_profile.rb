class RemoveSocialNetworksFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :facebook_url, :text
    remove_column :profiles, :twitter_url, :text
    remove_column :profiles, :gplus_url, :text
    remove_column :profiles, :instagram_url, :text
    remove_column :profiles, :vimeo_url, :text
    remove_column :profiles, :youtube_url, :text
    remove_column :profiles, :flickr_url, :text
    remove_column :profiles, :tumblr_url, :text
    remove_column :profiles, :gplus_on, :boolean, default: false
    remove_column :profiles, :instagram_on, :boolean, default: false
    remove_column :profiles, :vimeo_on, :boolean, default: false
    remove_column :profiles, :youtube_on, :boolean, default: false
    remove_column :profiles, :flickr_on, :boolean, default: false
    remove_column :profiles, :tumblr_on, :boolean, default: false
  end
end
