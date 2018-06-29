class AddDistrictToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :district, :string
  end
end
