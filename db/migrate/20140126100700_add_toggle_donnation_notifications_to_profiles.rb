class AddToggleDonnationNotificationsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :donation_notifications_on, :boolean, default: false
  end
end
