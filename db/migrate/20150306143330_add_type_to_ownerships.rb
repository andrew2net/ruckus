class AddTypeToOwnerships < ActiveRecord::Migration
  def change
    add_column :ownerships, :type, :string, default: 'AdminOwnership'
  end
end
