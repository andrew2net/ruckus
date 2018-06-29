class AddOauthFields < ActiveRecord::Migration
  def change
    add_column :oauth_accounts, :oauth_expires_at, :datetime
    add_column :oauth_accounts, :oauth_token, :string
  end
end
