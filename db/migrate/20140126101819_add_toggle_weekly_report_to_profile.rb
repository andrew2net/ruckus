class AddToggleWeeklyReportToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :weekly_report_on, :boolean, default: true
  end
end
