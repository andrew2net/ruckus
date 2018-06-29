class Admin::ProfilesStatsController < Admin::BaseController
  def index
    respond_to do |format|
      format.csv { send_data(csv_report.export) }
    end
  end

  private

  def csv_report
    @csv_report ||= ProfilesStat.new
  end
end
