class RemoveAddressFromProfile < ActiveRecord::Migration
  def up
    remove_column :profiles, :address
  end

  def down
    add_column :profiles, :address, :string
  end
end
