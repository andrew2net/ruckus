class DeAccountStatusChecker
  include Sidekiq::Worker

  sidekiq_options failures: :exhausted

  def perform(de_account_id, time_triggered = Time.now)
    de_account = DeAccount.find(de_account_id)

    if De::RecipientStatusChecker.new(de_account).is_active?
      de_account.update_column :is_active_on_de, true
    else
      DeAccountStatusChecker.perform_in(5.minutes, de_account_id, time_triggered)
    end
  end
end
