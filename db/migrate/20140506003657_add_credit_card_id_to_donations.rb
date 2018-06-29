class AddCreditCardIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :credit_card_id, :integer
  end
end
