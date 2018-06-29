class ChangeBackgroundImageInProfile < ActiveRecord::Migration
  def up
    add_column    :profiles, :background_image, :string
    remove_column :profiles, :background_image_id
  end

  def down
    add_column    :profiles, :background_image_id, :integer
    remove_column :profiles, :background_image
  end
end
