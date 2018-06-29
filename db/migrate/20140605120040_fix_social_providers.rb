class FixSocialProviders < ActiveRecord::Migration
  def up
    SocialPost.all.each do |social_post|
      provider = social_post.provider
      # because we don't want to trigger after_save callbacks
      social_post.update_column :provider, [provider].to_yaml
    end
  end

  def down
    SocialPost.all.each do |social_post|
      provider = social_post.provider.first
      social_post.update_column :provider, provider
    end
  end
end
