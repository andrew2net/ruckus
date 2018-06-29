class AddAgreementsToDemocracyengineAccounts < ActiveRecord::Migration
  def change
    add_column :democracyengine_accounts, :agreements, :text
  end
end
