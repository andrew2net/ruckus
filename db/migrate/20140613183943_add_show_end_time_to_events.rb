class AddShowEndTimeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :show_end_time, :boolean, fefault: false
  end
end
