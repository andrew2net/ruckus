module Chartable
  extend ActiveSupport::Concern

  module ClassMethods
    def count_by(period, start = 1.year.ago)
      case period
      when :week
        count_by_week(start)
      else
        count_by_month(start)
      end
    end

    def count_by_month(start = 1.year.ago)
      where(created_at: start.beginning_of_month..Time.now)
        .group("DATE(DATE_TRUNC('month', created_at))")
        .select("DATE(DATE_TRUNC('month', created_at)) as created_at, COUNT(created_at) as count")
        .order("created_at")
    end

    def count_by_week(start = 1.year.ago)
      where(created_at: start.beginning_of_month..Time.now)
        .group("DATE(DATE_TRUNC('week', created_at))")
        .select("DATE(DATE_TRUNC('week', created_at)) as created_at, COUNT(created_at) as count")
        .order("created_at")
    end
  end
end
