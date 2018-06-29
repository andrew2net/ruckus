class RemoveStateFromAccounts < ActiveRecord::Migration
  def up
    remove_column :accounts, :state
  end

  def down
    add_column :accounts, :state, :string
  end
end
