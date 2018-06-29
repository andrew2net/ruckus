class TheSubscription < ActiveRecord::Base
  self.table_name = :subscriptions
  belongs_to :user, class_name: 'TheUser'
end

class TheUser < ActiveRecord::Base
  self.table_name = :users
end

class CreateSubscriptions < ActiveRecord::Migration
  # just rename existing join table - because it's safer for production data
  def up
    rename_table :candidates_users, :subscriptions
    add_timestamps :subscriptions

    data = TheSubscription.includes(:user).map do |subscription|
      user = subscription.user
      [subscription.id, { created_at: user.created_at, updated_at: user.updated_at }]
    end.to_h

    TheSubscription.update(data.keys, data.values)
  end

  def down
    remove_timestamps :subscriptions
    rename_table :subscriptions, :candidates_users
  end
end
