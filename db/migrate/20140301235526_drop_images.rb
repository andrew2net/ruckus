class DropImages < ActiveRecord::Migration
  def up
    drop_table :images
  end

  def down
    create_table :images do |t|
      t.integer :candidate_id
      t.string  :file

      t.timestamps
    end

    add_index :images, :candidate_id
  end
end
