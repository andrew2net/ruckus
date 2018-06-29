class ChangeTitleMaxLength < ActiveRecord::Migration
  def up
    change_column :press_releases, :title, :text
    change_column :press_releases, :page_title, :text
    change_column :press_release_images, :press_release_url, :text
    change_column :press_release_images, :image, :text
  end

  def down
    change_column :press_releases, :title, :string
    change_column :press_releases, :page_title, :string
    change_column :press_release_images, :press_release_url, :string
    change_column :press_release_images, :image, :string
  end
end
