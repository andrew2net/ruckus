class AddIndexesToRequests < ActiveRecord::Migration
  def change
    add_index :requests, [:requestable_type, :requestable_id]
    add_index :requests, :created_at
    add_index :accounts, :created_at
  end
end
