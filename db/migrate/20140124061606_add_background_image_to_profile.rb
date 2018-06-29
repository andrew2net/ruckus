class AddBackgroundImageToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :background_image, :string
  end
end
