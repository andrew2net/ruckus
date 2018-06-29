class AddIndexToCandidatesUsers < ActiveRecord::Migration
  def change
    add_index "candidates_users", ["candidate_id"], name: "index_candidates_users_on_candidate_id", using: :btree
    add_index "candidates_users", ["user_id"], name: "index_candidates_users_on_user_id", using: :btree
  end
end
