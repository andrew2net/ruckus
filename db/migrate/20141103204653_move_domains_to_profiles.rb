class MoveDomainsToProfiles < ActiveRecord::Migration
  def up
    rename_column :domains, :account_id, :profile_id

    Domain.where.not(profile_id: nil).find_each do |domain|
      domain.update_column(:profile_id, Profile.where(account_id: domain.profile_id).pluck(:id).first)
    end
  end

  def down
    rename_column :domains, :profile_id, :account_id

    Domain.where.not(account_id: nil).find_each do |domain|
      domain.update_column(:account_id, Profile.where(id: domain.account_id).pluck(:account_id).first)
    end
  end
end
