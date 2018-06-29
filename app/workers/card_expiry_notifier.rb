class CardExpiryNotifier
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  sidekiq_options failures: :exhausted

  # "try" is used because staging has many profiles updated through console

  def perform
    CreditCard.about_to_expire.each do |card|
      profile = card.credit_card_holder.try(:profile)

      if profile.present?
        account = profile.try(:account)
        PremiumMailer.card_expiry_notification(account, profile, card).deliver if account.present?
      end
    end
  end
end
