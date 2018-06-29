class ChangeDonationNotificationsDefaultValue < ActiveRecord::Migration
  def change
    change_column :profiles, :donation_notifications_on, :boolean, default: true
  end
end
