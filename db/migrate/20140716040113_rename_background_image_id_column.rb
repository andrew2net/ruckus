class RenameBackgroundImageIdColumn < ActiveRecord::Migration
  def up
    rename_column :profiles, :background_image_id, :background_image_medium_id
  end

  def down
    rename_column :profiles, :background_image_medium_id, :background_image_id
  end
end
