class AddLastPaymentToCreditCardHolders < ActiveRecord::Migration
  def change
    add_column :credit_card_holders, :last_payment, :datetime
  end
end
