class RemoveInternalDefaultValueFromDomains < ActiveRecord::Migration
  def up
    change_column_default :domains, :internal, nil
  end

  def down
    change_column_default :domains, :internal, true
  end
end
