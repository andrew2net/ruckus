class CreateOauthAccounts < ActiveRecord::Migration
  def up
    create_table :oauth_accounts do |t|
      t.references :candidate, index: true
      t.string :uid
      t.string :provider
      t.string :url

      t.timestamps
    end

    add_index :oauth_accounts, :uid
    remove_column :profiles, :twitter_url
  end

  def down
    drop_table :oauth_accounts
    add_column :profiles, :twitter_url, :string
  end
end
