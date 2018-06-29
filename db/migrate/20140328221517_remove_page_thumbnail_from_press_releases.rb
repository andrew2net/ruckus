class RemovePageThumbnailFromPressReleases < ActiveRecord::Migration
  def up
    remove_column :press_releases, :page_thumbnail
  end

  def down
    add_column :press_releases, :page_thumbnail, :string
  end
end
