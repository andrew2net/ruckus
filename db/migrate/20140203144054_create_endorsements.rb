class CreateEndorsements < ActiveRecord::Migration
  def change
    create_table :endorsements do |t|
      t.integer :candidate_id
      t.string :title
      t.string :url
      t.string :page_title
      t.boolean :page_title_enabled, default: true
      t.string :page_date
      t.boolean :page_date_enabled, default: true
      t.boolean :page_thumbnail_enabled, default: true
      t.string :page_thumbnail
      t.integer :position

      t.timestamps
    end

    add_index :endorsements, :candidate_id
  end
end
