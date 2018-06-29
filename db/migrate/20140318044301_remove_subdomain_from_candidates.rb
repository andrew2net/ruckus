class RemoveSubdomainFromCandidates < ActiveRecord::Migration
  def change
    remove_column :candidates, :subdomain
  end
end
