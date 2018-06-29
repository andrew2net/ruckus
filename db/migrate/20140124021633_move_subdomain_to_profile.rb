class MoveSubdomainToProfile < ActiveRecord::Migration
  def up
    add_column    :profiles, :subdomain, :string
    add_index     :profiles, :subdomain
    remove_column :users,    :subdomain
  end

  def down
    add_column    :users,    :subdomain, :string
    add_index     :users,    :subdomain
    remove_column :profiles, :subdomain
  end
end
