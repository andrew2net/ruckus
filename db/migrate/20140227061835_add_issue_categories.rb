class AddIssueCategories < ActiveRecord::Migration
  def change
    create_table :issue_categories do |t|
      t.string :name
      t.integer :candidate_id
      t.timestamps
    end
  end
end
