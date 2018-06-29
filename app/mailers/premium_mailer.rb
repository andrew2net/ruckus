class PremiumMailer < BaseMailer
  def profile_upgrading_notification(emails, profile, amount)
    @profile, @amount = profile, amount
    mail(to: emails, subject: 'Upgrading receipt')
  end

  def card_expiry_notification(account, profile, card)
    @profile = profile
    @card = card
    mail(to: account.email, subject: 'Your credit card is about to expire!')
  end

  def discontinue_notification(card_holder)
    @profile = card_holder.profile
    account = @profile.account
    @card = card_holder.credit_card
    mail(to: account.email, subject: 'Your site is no longer premium!')
  end
end
