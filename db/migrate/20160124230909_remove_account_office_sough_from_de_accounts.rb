class RemoveAccountOfficeSoughFromDeAccounts < ActiveRecord::Migration
  def change
    remove_column :de_accounts, :account_office_sough, :string
  end
end
