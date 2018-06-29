class AddJobIdToCreditCardHolders < ActiveRecord::Migration
  def up
    add_column :credit_card_holders, :job_id, :string
  end

  def down
    remove_column :credit_card_holders, :job_id
  end
end
