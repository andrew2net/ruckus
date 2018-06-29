class RegenerateNames < ActiveRecord::Migration
  def up
    Profile.all.each do |profile|
      if profile.name.blank?
        profile.update_column :name, [profile.first_name, profile.last_name].join(' ')
      end
    end
  end

  def down
    Profile.update_all(name: nil)
  end
end
