class AddDefaultValueToHeroUnitOn < ActiveRecord::Migration
  def change
    change_column_default :profiles, :hero_unit_on, false
  end
end
