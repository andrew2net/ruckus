class PremiumPeriodicPayments
  include Sidekiq::Worker

  def perform
    current_time = Time.current

    CreditCardHolder.joins(profile: {ownerships: :account})
                    .where('last_payment IS NOT NULL AND last_payment < ?', current_time - 1.month)
                    .select(&:valid?)
                    .each do |card_holder|
      if !De::ProfileUpgrader.new(card_holder, logger).process
        card_holder.profile.update_column :suspended, true
        PremiumMailer.discontinue_notification(card_holder)
      end
    end
  end
end
