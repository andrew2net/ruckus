class AddShowStartTimeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :show_start_time, :boolean, default: false
  end
end
