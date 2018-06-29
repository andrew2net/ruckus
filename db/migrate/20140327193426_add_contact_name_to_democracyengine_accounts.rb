class AddContactNameToDemocracyengineAccounts < ActiveRecord::Migration
  def change
    add_column :democracyengine_accounts, :contact_first_name, :string
    add_column :democracyengine_accounts, :contact_address, :string
    add_column :democracyengine_accounts, :contact_city, :string
    add_column :democracyengine_accounts, :contact_state, :string
    add_column :democracyengine_accounts, :contact_zip, :string
    add_column :democracyengine_accounts, :candidate_party, :string
  end
end
