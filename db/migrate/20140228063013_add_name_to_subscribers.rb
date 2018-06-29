class AddNameToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :name, :string
  end
end
