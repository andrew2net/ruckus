class RemoveConstituencyFromProfiles < ActiveRecord::Migration
  def up
    Profile.all.each do |profile|
      constituency = profile.constituency
      district = profile.district

      unless district.present?
        profile.update_column :district, constituency
      end
    end
    remove_column :profiles, :constituency, :string
  end

  def down
    add_column :profiles, :constituency, :string

    Profile.all.each do |profile|
      district = profile.district
      profile.update_column :constituency, district
    end
  end
end
