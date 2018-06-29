class AddEndorsementsOnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :endorsements_on, :boolean, default: true
  end
end
