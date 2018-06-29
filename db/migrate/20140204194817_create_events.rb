class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.string :time_zone
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.text :description
      t.integer :candidate_id

      t.timestamps
    end

    add_index :events, :candidate_id
  end
end
