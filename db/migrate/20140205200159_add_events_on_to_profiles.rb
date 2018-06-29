class AddEventsOnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :events_on, :boolean, default: true
  end
end
