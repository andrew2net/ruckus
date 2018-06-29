class RemoveJobIdFromCreditCardHolders < ActiveRecord::Migration
  def change
    remove_column :credit_card_holders, :job_id, :string
  end
end
