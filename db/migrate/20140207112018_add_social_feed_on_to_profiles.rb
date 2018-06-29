class AddSocialFeedOnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :social_feed_on, :boolean, default: true
  end
end
