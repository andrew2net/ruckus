class AddToggleDonnationsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :donations_on, :boolean, default: true
  end
end
