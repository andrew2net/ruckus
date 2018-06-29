class CopyProfileIds < ActiveRecord::Migration
  def up
    Profile.all.each do |profile|
      profile.account.update_column :profile_id, profile.id
    end
  end

  def down
    #not required
  end
end
