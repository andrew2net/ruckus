class AddIsActiveOnDeToDemocracyengineAccounts < ActiveRecord::Migration
  def change
    add_column :democracyengine_accounts, :is_active_on_de, :boolean, default: false
  end
end
