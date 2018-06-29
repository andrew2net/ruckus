class AddSuspendedToProfiles < ActiveRecord::Migration
  def change
    # if profile from premium became basic due to non payment
    add_column :profiles, :suspended, :boolean, default: false
  end
end
