class AddPremiumByDefaultToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :premium_by_default, :boolean, default: false
  end
end
