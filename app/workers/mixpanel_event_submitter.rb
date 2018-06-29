class MixpanelEventSubmitter
  include Sidekiq::Worker

  sidekiq_options failures: :exhausted

  def perform(account_id, event_name, properties)
    @token = ANALYTICS['mixpanel_id']
    @tracker = Mixpanel::Tracker.new(@token)
    @tracker.track(account_id, event_name, properties)
  end
end
