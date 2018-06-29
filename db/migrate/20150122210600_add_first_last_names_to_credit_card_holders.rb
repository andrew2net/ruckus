class AddFirstLastNamesToCreditCardHolders < ActiveRecord::Migration
  def up
    add_column :credit_card_holders, :first_name, :string
    add_column :credit_card_holders, :last_name, :string
    remove_column :credit_card_holders, :name
  end

  def down
    add_column :credit_card_holders, :name, :string
    remove_column :credit_card_holders, :first_name
    remove_column :credit_card_holders, :last_name
  end
end
