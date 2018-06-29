class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :scorable_id
      t.string :scorable_type
      t.string :ip
      t.timestamps
    end
  end
end
