class AddCurrentProfileIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :profile_id, :integer
    add_index :accounts, :profile_id
  end
end
