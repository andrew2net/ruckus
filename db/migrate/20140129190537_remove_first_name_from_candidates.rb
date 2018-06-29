class RemoveFirstNameFromCandidates < ActiveRecord::Migration
  def change
    remove_column :candidates, :first_name, :string
  end
end
