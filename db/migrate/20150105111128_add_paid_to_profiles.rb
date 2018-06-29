class AddPaidToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :paid, :boolean, default: false
  end
end
