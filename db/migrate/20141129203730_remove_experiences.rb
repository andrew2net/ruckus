class RemoveExperiences < ActiveRecord::Migration
  def up
    drop_table :experiences
  end

  def down
    create_table :experiences do |t|
      t.integer :candidate_id
      t.string :title
      t.string :organization
      t.integer :start_year
      t.integer :end_year

      t.timestamps
    end

    add_index :experiences, :candidate_id
  end
end
