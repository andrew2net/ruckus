class AddHeroUnitToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :hero_unit, :string
  end
end
