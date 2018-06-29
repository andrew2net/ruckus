class MoveDeAccountsToProfile < ActiveRecord::Migration
  def up
    rename_column :democracyengine_accounts, :account_id, :profile_id
    rename_column :donations, :account_id, :profile_id

    # ActiveRecord::Base.transaction do
    #   DemocracyengineAccount.where.not(profile_id: nil).find_each do |de_account|
    #     profile_id = Profile.where(account_id: de_account.profile_id).pluck(:id).first
    #     de_account.update_column(:profile_id, profile_id)
    #   end

    #   Donation.where.not(profile_id: nil).find_each do |donation|
    #     profile_id = Profile.where(account_id: donation.profile_id).pluck(:id).first
    #     donation.update_column(:profile_id, profile_id)
    #   end
    # end
  end

  def down
    rename_column :democracyengine_accounts, :profile_id, :account_id
    rename_column :donations, :profile_id, :account_id

    # ActiveRecord::Base.transaction do
    #   DemocracyengineAccount.where.not(account_id: nil).find_each do |de_account|
    #     account_id = Profile.where(id: de_account.account_id).pluck(:account_id).first
    #     de_account.update_column(:account_id, account_id)
    #   end

    #   Donation.where.not(account_id: nil).find_each do |donation|
    #     account_id = Profile.where(id: donation.account_id).pluck(:account_id).first
    #     donation.update_column(:account_id, account_id)
    #   end
    # end
  end
end
