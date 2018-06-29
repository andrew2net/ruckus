class RenameUsersToCandidates < ActiveRecord::Migration
  def change
    rename_table :users, :candidates
    rename_column :profiles, :user_id, :candidate_id
  end
end
