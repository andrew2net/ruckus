class MoveSubdomainToCandidate < ActiveRecord::Migration
  def up
    add_column    :candidates, :subdomain, :string
    add_index     :candidates, :subdomain

    remove_column :profiles,   :subdomain
  end

  def down
    add_column    :profiles,   :subdomain, :string
    add_index     :profiles,   :subdomain

    remove_column :candidates, :subdomain
  end
end
