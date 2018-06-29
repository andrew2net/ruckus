class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :candidate_id
      t.string  :file

      t.timestamps
    end

    add_index :images, :candidate_id
  end
end
