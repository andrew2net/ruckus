class AddSwitchesToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :issues_on, :boolean, default: true
    add_column :profiles, :media_on, :boolean, default: true
    add_column :profiles, :biography_on, :boolean, default: true
    add_column :profiles, :signup_notifications_on, :boolean, default: true
  end
end
