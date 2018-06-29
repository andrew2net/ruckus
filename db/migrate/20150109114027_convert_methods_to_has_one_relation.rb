class ConvertMethodsToHasOneRelation < ActiveRecord::Migration
  def up
    add_belongs_to :accounts, :profile, index: true

    Ownership.where(primary: true).all.each do |ownership|
      ownership.account.update_column :profile_id, ownership.profile_id
    end

    remove_column :ownerships, :primary, :boolean, default: false
  end

  def down
    add_column :ownerships, :primary, :boolean, default: false

    Account.each do |account|
      Ownership.where(account_id: account.id, profile_id: account.profile.id).update_all primary: true
    end

    remove_belongs_to :accounts, :profile, index: true
  end
end
