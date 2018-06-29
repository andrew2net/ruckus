class RecreateImagesAgain < ActiveRecord::Migration
  def up
    Medium.all.each do |medium|
      medium.delay.recreate_image_versions
    end

    Profile.all.each do |profile|
      profile.delay.recreate_image_versions
    end
  end

  def down
    Medium.all.each do |medium|
      medium.delay.recreate_image_versions
    end

    Profile.all.each do |profile|
      profile.delay.recreate_image_versions
    end
  end
end
