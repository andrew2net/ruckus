class DefaultMaxDonationCap < ActiveRecord::Migration
  def up
    change_column :democracyengine_accounts, :max_donation_cap, :integer, default: nil
  end

  def down
    change_column :democracyengine_accounts, :max_donation_cap, :integer
  end
end
