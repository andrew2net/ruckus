class AddCouponIdToCreditCardHolder < ActiveRecord::Migration
  def up
    add_column :credit_card_holders, :coupon_id, :integer
    add_index :credit_card_holders, :coupon_id
  end

  def down
    remove_column :credit_card_holders, :coupon_id
  end
end
