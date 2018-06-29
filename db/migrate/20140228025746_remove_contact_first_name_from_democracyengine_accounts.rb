class RemoveContactFirstNameFromDemocracyengineAccounts < ActiveRecord::Migration
  def change
    remove_column :democracyengine_accounts, :contact_first_name, :string
    remove_column :democracyengine_accounts, :contact_address, :string
    remove_column :democracyengine_accounts, :contact_city, :string
    remove_column :democracyengine_accounts, :contact_state, :string
    remove_column :democracyengine_accounts, :contact_zip, :string
  end
end
