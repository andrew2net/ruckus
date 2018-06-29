class ChangeVideoUrlType < ActiveRecord::Migration
  # change all fields that may contain URL to 'text'
  def up
    change_column :media, :video_url, :text
    change_column :oauth_accounts, :url, :text
    change_column :press_releases, :url, :text
    change_column :profiles, :facebook_url, :text
    change_column :profiles, :twitter_url, :text
    change_column :profiles, :gplus_url, :text
    change_column :profiles, :instagram_url, :text
    change_column :profiles, :vimeo_url, :text
    change_column :profiles, :youtube_url, :text
    change_column :profiles, :flickr_url, :text
    change_column :profiles, :tumblr_url, :text
  end

  def down
    change_column :media, :my_column, :string
    change_column :oauth_accounts, :url, :string
    change_column :press_releases, :url, :string
    change_column :profiles, :facebook_url, :string
    change_column :profiles, :twitter_url, :string
    change_column :profiles, :gplus_url, :string
    change_column :profiles, :instagram_url, :string
    change_column :profiles, :vimeo_url, :string
    change_column :profiles, :youtube_url, :string
    change_column :profiles, :flickr_url, :string
    change_column :profiles, :tumblr_url, :string
  end
end
