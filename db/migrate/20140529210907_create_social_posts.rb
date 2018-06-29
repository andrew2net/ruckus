class CreateSocialPosts < ActiveRecord::Migration
  def change
    create_table :social_posts do |t|
      t.references :candidate
      t.string :provider
      t.text :message
      t.string :remote_id

      t.timestamps
    end
  end
end
