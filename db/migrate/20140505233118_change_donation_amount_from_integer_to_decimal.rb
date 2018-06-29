class ChangeDonationAmountFromIntegerToDecimal < ActiveRecord::Migration
  def up
    change_column :donations, :amount, :decimal
  end

  def down
    change_column :donations, :amount, :integer
  end
end
