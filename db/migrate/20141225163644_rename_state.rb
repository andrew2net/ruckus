class RenameState < ActiveRecord::Migration
  def change
    rename_column :oauth_accounts, :state, :aasm_state
    add_index :oauth_accounts, :aasm_state
  end
end
