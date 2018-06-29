class AddCreditCardHolderToProfiles < ActiveRecord::Migration
  def change
    add_reference :profiles, :credit_card_holder, index: true
  end
end
