class RenamePhotoIdToPhotoMediumIdInProfiles < ActiveRecord::Migration
  def change
    rename_column :profiles, :photo_id, :photo_medium_id
  end
end
