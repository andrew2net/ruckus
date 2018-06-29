class AddBackgroundCroppingLogic < ActiveRecord::Migration
  def change
    add_column :profiles, :background_image_cropping_width, :integer
    add_column :profiles, :background_image_cropping_height, :integer
    add_column :profiles, :background_image_cropping_offset_y, :integer
    add_column :profiles, :background_image_cropping_offset_x, :integer
  end
end
