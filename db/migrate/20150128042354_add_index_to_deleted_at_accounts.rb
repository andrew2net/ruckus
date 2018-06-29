class AddIndexToDeletedAtAccounts < ActiveRecord::Migration
  def up
    add_index :accounts, :deleted_at
  end

  def down
    remove_index :accounts, :deleted_at
  end
end
