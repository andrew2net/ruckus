class AddIndexesToScores < ActiveRecord::Migration
  def change
    add_index "scores", ["scorable_id"], name: "index_scores_on_scorable_id", using: :btree
    add_index "scores", ["scorable_type"], name: "index_scores_on_scorable_type", using: :btree
  end
end
