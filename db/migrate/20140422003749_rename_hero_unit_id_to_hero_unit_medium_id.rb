class RenameHeroUnitIdToHeroUnitMediumId < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.rename :hero_unit_id, :hero_unit_medium_id
    end
  end
end
