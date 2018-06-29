class AddAboutMeToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :about_me, :text
  end
end
