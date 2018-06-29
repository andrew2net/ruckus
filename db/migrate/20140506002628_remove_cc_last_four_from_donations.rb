class RemoveCcLastFourFromDonations < ActiveRecord::Migration
  def change
    remove_column :donations, :cc_last_four, :string
  end
end
