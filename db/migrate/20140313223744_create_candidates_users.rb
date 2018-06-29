class CreateCandidatesUsers < ActiveRecord::Migration
  def change
    create_table :candidates_users do |t|
      t.integer :candidate_id
      t.integer :user_id
    end
  end
end
