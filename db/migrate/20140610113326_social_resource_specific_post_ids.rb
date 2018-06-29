class SocialResourceSpecificPostIds < ActiveRecord::Migration
  def up
    add_column :social_posts, :twitter_remote_id, :string
    add_column :social_posts, :facebook_remote_id, :string

    remove_column :social_posts, :remote_id, :string
  end

  def down
    add_column :social_posts, :remote_id, :string

    remove_column :social_posts, :twitter_remote_id, :string
    remove_column :social_posts, :facebook_remote_id, :string
  end
end
