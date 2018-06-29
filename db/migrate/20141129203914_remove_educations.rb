class RemoveEducations < ActiveRecord::Migration
  def up
    drop_table :educations
  end

  def down
    create_table :educations do |t|
      t.string :alma_mater
      t.string :degree
      t.integer :candidate_id

      t.timestamps
    end

    add_index :educations, :candidate_id
  end
end
