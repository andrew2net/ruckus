class RemoveColumnAccountIdFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :account_id, :integer
  end
end
