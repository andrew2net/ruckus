class CreateCreditCardHolders < ActiveRecord::Migration
  def change
    create_table :credit_card_holders do |t|
      t.string :name
      t.string :state
      t.string :city
      t.string :zip
      t.string :address
      t.string :token
      t.belongs_to :credit_card, index: true

      t.timestamps
    end
  end
end
