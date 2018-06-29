class AddDeletedAtToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :deleted_at, :datetime
  end
end
