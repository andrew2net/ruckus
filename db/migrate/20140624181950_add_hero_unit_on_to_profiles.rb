class AddHeroUnitOnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :hero_unit_on, :boolean
  end
end
