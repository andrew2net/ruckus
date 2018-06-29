class RemoveProfileFromAccounts < ActiveRecord::Migration
  def change
    remove_reference :accounts, :profile, index: true
  end
end
