class RenameDemocracyengineAccountToDeAccount < ActiveRecord::Migration
  def change
    rename_table :democracyengine_accounts, :de_accounts
  end
end
