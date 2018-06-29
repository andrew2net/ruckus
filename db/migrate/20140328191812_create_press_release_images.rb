class CreatePressReleaseImages < ActiveRecord::Migration
  def change
    create_table :press_release_images do |t|
      t.references :candidate
      t.string     :press_release_url
      t.string     :image
      t.boolean    :active, default: false
    end

    add_index :press_release_images, [:candidate_id, :press_release_url], name: 'index_press_release_images_on_press_release_url'
    add_index :press_releases, [:candidate_id, :url]
  end
end
