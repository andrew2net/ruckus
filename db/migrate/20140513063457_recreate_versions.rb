class RecreateVersions < ActiveRecord::Migration
  def up
    Medium.all.each do |medium|
      medium.image.recreate_versions! if medium.image.present?
    end
    Profile.all.each do |profile|
      profile.background_image.recreate_versions! if profile.background_image.present?
      profile.photo.recreate_versions! if profile.photo.present?
      profile.hero_unit.recreate_versions! if profile.hero_unit.present?
    end

    rescue NameError
      puts 'Model Profile or Medium does not exist'
  end

  def down
  end
end
