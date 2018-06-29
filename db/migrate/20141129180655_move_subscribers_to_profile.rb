class MoveSubscribersToProfile < ActiveRecord::Migration
  def up
    rename_column :questions, :account_id, :profile_id
    rename_column :subscriptions, :account_id, :profile_id

    Question.where.not(profile_id: nil).find_each do |question|
      question.update_column(:profile_id, Profile.where(account_id: question.profile_id).pluck(:id).first)
    end

    Subscription.where.not(profile_id: nil).find_each do |subscription|
      subscription.update_column(:profile_id, Profile.where(account_id: subscription.profile_id).pluck(:id).first)
    end

    drop_table :subscribers
  end

  def down
    rename_column :questions, :profile_id, :account_id
    rename_column :subscriptions, :profile_id, :account_id

    Question.where.not(account_id: nil).find_each do |question|
      question.update_column(:account_id, Profile.where(id: question.account_id).pluck(:account_id).first)
    end

    Subscription.where.not(account_id: nil).find_each do |subscription|
      subscription.update_column(:account_id, Profile.where(id: subscription.account_id).pluck(:account_id).first)
    end

    create_table :subscribers do |t|
      t.string :email
      t.boolean :subscribed, default: true
      t.integer :profile_id

      t.timestamps
    end

    add_index :subscribers, :profile_id
  end
end
