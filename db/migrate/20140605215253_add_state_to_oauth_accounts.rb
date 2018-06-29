class AddStateToOauthAccounts < ActiveRecord::Migration
  def change
    add_column :oauth_accounts, :state, :string, default: 'active'
  end
end
