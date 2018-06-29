class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.text :data
      t.integer :requestable_id
      t.string :requestable_type

      t.timestamps
    end

  end
end
