class MoveProfilesAndAccountsToOwnerships < ActiveRecord::Migration
  def up
    Profile.all.each do |profile|
      Ownership.create account_id: profile.account_id,
                       profile_id: profile.id
    end

    Account.all.each do |account|
      Ownership.where(account_id: account.id,
                      profile_id: account.profile_id).update_all primary: true
    end
  end

  def down
    Ownership.all.each do |ownership|
      ownership.profile.update_column :account_id, ownership.account_id
      ownership.account.update_column :profile_id, ownership.profile_id if ownership.primary?
    end
  end
end
