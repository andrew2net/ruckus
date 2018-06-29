class AddTimezoneDefaultValue < ActiveRecord::Migration
  def up
    change_column_default :events, :time_zone, 'UTC'
  end

  def down
    change_column_default :events, :time_zone, nil
  end
end
