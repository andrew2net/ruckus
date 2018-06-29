class RemoveDemocracyengineRequestErrorsFromDonations < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.column_exists?(:donations, :democracyengine_request_errors)
      Donation.where('democracyengine_request_errors IS NOT NULL').destroy_all
    end

    remove_column :donations, :democracyengine_request_errors
  end

  def down
    add_column :donations, :democracyengine_request_errors, :text
  end
end
