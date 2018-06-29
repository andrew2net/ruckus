class RenameEndorsementsOnToPressOnInProfiles < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.rename :endorsements_on, :press_on
    end
  end
end
