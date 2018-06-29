class MoveSocialsToProfile < ActiveRecord::Migration
  def up
    rename_column :oauth_accounts, :account_id, :profile_id
    rename_column :social_posts, :account_id, :profile_id

    OauthAccount.where.not(profile_id: nil).find_each do |oauth_account|
      oauth_account.update_column(:profile_id, Profile.where(account_id: oauth_account.profile_id).pluck(:id).first)
    end

    SocialPost.where.not(profile_id: nil).find_each do |social_post|
      social_post.update_column(:profile_id, Profile.where(account_id: social_post.profile_id).pluck(:id).first)
    end
  end

  def down
    rename_column :oauth_account, :profile_id, :account_id
    rename_column :social_posts, :profile_id, :account_id

    OauthAccount.where.not(account_id: nil).find_each do |oauth_account|
      oauth_account.update_column(:account_id, Profile.where(id: oauth_account.account_id).pluck(:account_id).first)
    end

    SocialPost.where.not(account_id: nil).find_each do |social_post|
      social_post.update_column(:account_id, Profile.where(id: social_post.account_id).pluck(:account_id).first)
    end
  end
end
