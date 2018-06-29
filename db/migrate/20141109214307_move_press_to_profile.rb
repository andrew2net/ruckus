class MovePressToProfile < ActiveRecord::Migration
  def up
    rename_column :press_releases, :account_id, :profile_id
    rename_column :press_release_images, :account_id, :profile_id

    PressRelease.where.not(profile_id: nil).find_each do |press|
      press.update_column(:profile_id, Profile.where(account_id: press.profile_id).pluck(:id).first)
    end

    PressReleaseImage.where.not(profile_id: nil).find_each do |image|
      image.update_column(:profile_id, Profile.where(account_id: image.profile_id).pluck(:id).first)
    end
  end

  def down
    rename_column :press_releases, :profile_id, :account_id
    rename_column :press_release_images, :profile_id, :account_id

    PressRelease.where.not(account_id: nil).find_each do |press|
      press.update_column(:account_id, Profile.where(id: press.account_id).pluck(:account_id).first)
    end

    PressReleaseImage.where.not(account_id: nil).find_each do |image|
      image.update_column(:account_id, Profile.where(id: image.account_id).pluck(:account_id).first)
    end
  end
end
