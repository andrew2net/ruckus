class CreateCampaingPagePosts < ActiveRecord::Migration
  def change
    create_table :campaing_page_posts do |t|
      t.references :social_post, index: true, null: false
      t.references :campaing_page, index: true
      t.string :remote_id, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
