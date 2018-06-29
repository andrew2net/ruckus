class RemoveLastNameFromCandidates < ActiveRecord::Migration
  def change
    remove_column :candidates, :last_name, :string
  end
end
