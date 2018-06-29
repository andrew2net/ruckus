class AddSubdomainToUser < ActiveRecord::Migration
  def change
    add_column :users, :subdomain, :string
    add_index :users, :subdomain
  end
end
