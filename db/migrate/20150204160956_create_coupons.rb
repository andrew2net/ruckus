class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.datetime :expired_at
      t.decimal :discount
      t.string :encrypted_code
      t.timestamps
    end
  end
end
