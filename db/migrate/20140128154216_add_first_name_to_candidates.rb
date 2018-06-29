class AddFirstNameToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :first_name, :string
  end
end
