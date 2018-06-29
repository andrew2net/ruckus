class AddOwnerToProfiles < ActiveRecord::Migration
  def change
    add_reference :profiles, :owner, index: true
  end
end
