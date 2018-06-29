class ChangeColumnTypesInProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :photo, :string
    remove_column :profiles, :background_image, :string

    add_column :profiles, :photo_id, :integer
    add_column :profiles, :background_image_id, :integer
    add_column :profiles, :hero_unit_id, :integer
    add_column :profiles, :media_stream_ids, :text
  end
end
