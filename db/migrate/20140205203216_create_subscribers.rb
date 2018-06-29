class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string :email
      t.boolean :subscribed, default: true
      t.integer :candidate_id

      t.timestamps
    end

    add_index :subscribers, :candidate_id
  end
end
