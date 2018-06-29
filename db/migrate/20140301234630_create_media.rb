class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :image
      t.integer :candidate_id
      t.string :video_url
      t.string :video_embed_url

      t.timestamps
    end
  end
end
