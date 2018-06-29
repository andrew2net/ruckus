class AddIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :title
      t.text :description
      t.integer :position
      t.integer :issue_category_id
      t.integer :candidate_id
      t.timestamps
    end
  end
end
