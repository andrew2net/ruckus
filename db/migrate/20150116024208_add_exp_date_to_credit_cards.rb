class AddExpDateToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :exp_date, :date
  end
end
