class AddInternalToDomain < ActiveRecord::Migration
  def up
    add_column :domains, :internal, :boolean, default: true
    remove_column :domains, :primary
  end

  def down
    add_column :domains, :primary, :boolean, default: false
    remove_column :domains, :internal
  end
end
