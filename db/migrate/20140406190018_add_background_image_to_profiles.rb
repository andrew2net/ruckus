class AddBackgroundImageToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :background_image_id, :integer
  end
end
