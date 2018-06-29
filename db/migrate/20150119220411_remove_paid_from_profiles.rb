class RemovePaidFromProfiles < ActiveRecord::Migration
  def up
    remove_column :profiles, :paid
  end

  def down
    add_column :profiles, :paid, :boolean, default: false
  end
end
