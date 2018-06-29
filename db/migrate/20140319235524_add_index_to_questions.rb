class AddIndexToQuestions < ActiveRecord::Migration
  def change
    add_index "questions", ["candidate_id"], name: "index_questions_on_candidate_id", using: :btree
    add_index "questions", ["user_id"], name: "index_questions_on_user_id", using: :btree
  end
end
