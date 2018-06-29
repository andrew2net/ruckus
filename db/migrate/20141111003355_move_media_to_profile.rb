class MoveMediaToProfile < ActiveRecord::Migration
  def up
    rename_column :media, :account_id, :profile_id

    Medium.where.not(profile_id: nil).find_each do |medium|
      medium.update_column(:profile_id, Profile.where(account_id: medium.profile_id).pluck(:id).first)
    end
  end

  def down
    rename_column :media, :profile_id, :account_id

    Medium.where.not(account_id: nil).find_each do |medium|
      medium.update_column(:account_id, Profile.where(id: medium.account_id).pluck(:account_id).first)
    end
  end
end
