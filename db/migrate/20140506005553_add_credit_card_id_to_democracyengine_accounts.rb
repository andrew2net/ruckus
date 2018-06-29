class AddCreditCardIdToDemocracyengineAccounts < ActiveRecord::Migration
  def change
    add_column :democracyengine_accounts, :credit_card_id, :integer
  end
end
