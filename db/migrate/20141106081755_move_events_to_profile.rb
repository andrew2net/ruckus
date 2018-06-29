class MoveEventsToProfile < ActiveRecord::Migration
  def up
    rename_column :events, :account_id, :profile_id

    Event.where.not(profile_id: nil).find_each do |event|
      event.update_column(:profile_id, Profile.where(account_id: event.profile_id).pluck(:id).first)
    end
  end

  def down
    rename_column :events, :profile_id, :account_id

    Event.where.not(account_id: nil).find_each do |event|
      event.update_column(:account_id, Profile.where(id: event.account_id).pluck(:account_id).first)
    end
  end
end
