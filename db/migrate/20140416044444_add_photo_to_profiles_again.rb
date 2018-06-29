class AddPhotoToProfilesAgain < ActiveRecord::Migration
  def change
    add_column :profiles, :photo, :string
  end
end
