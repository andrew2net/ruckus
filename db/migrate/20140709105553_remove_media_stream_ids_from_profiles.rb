class RemoveMediaStreamIdsFromProfiles < ActiveRecord::Migration
  def up
    ActiveRecord::Migration.verbose = false
    remove_column :profiles, :media_stream_ids, :string
    ActiveRecord::Migration.verbose = true
  end

  def down
    ActiveRecord::Migration.verbose = false
    add_column :profiles, :media_stream_ids, :string
    ActiveRecord::Migration.verbose = true
  end
end
