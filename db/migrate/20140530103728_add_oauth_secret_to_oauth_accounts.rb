class AddOauthSecretToOauthAccounts < ActiveRecord::Migration
  def change
    add_column :oauth_accounts, :oauth_secret, :string
  end
end
