class RemoveNameFromProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :name, :string
  end
end
