class AddPhotoCropToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :photo_cropping_width, :integer
    add_column :profiles, :photo_cropping_offset_x, :integer
    add_column :profiles, :photo_cropping_offset_y, :integer
  end
end
