class AddActiveToProfiles < ActiveRecord::Migration
  def up
    add_column :profiles, :active, :boolean, default: true
  end

  def down
    remove_column :profiles, :active
  end
end
