class AddSocialFieldsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :facebook_on, :boolean, default: false
    add_column :profiles, :twitter_url, :string
    add_column :profiles, :twitter_on, :boolean, default: false
    add_column :profiles, :gplus_url, :string
    add_column :profiles, :gplus_on, :boolean, default: false
    add_column :profiles, :instagram_url, :string
    add_column :profiles, :instagram_on, :boolean, default: false
    add_column :profiles, :vimeo_url, :string
    add_column :profiles, :vimeo_on, :boolean, default: false
    add_column :profiles, :youtube_url, :string
    add_column :profiles, :youtube_on, :boolean, default: false
    add_column :profiles, :flickr_url, :string
    add_column :profiles, :flickr_on, :boolean, default: false
    add_column :profiles, :tumblr_url, :string
    add_column :profiles, :tumblr_on, :boolean, default: false
  end
end
