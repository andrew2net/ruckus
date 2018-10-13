class AccountMailer < BaseMailer
  include Sidekiq::Mailer

  def welcome_email(account_id)
    @account = Account.find account_id
    email_with_name = "#{@account.profile.name} <#{@account.email}>"
    mail(to: email_with_name, subject: 'Your Powerful New Website is Ready!')
  end

  def donation_notification(account_id, donation_id)
    @account = Account.find account_id
    @donation = Donation.find donation_id
    email_with_name = "#{@account.profile.name} <#{@account.email}>"
    mail(to: email_with_name, subject: 'New Donation Received!')
    logger.info "Sending donation notification to recipient #{@account.email} is completed."
  end

  def donor_donation_notification(donation_id)
    @donation = Donation.find donation_id
    mail(to: "#{@donation.donor_name} <#{@donation.donor_email}>", subject: 'Your donation is processing')
    logger.info "Sending donation notification to donor #{@donation.donor_email} is completed."
  end

  def profile_removal_notification(account_id, profile_id, removed)
    @account = Account.with_deleted.find account_id
    @profile = Profile.find profile_id
    @account_removed = removed
    mail(to: @account.email, subject: 'Your account was disabled')
  end

  def support_message(msg_id)
    msg = SupportMessage.find msg_id
    @message = msg.message
    email_with_name = "#{msg.name} <#{msg.email}>"
    mail(to: admin_email, from: email_with_name, subject: msg.subject) do |format|
      format.html { render layout: false }
    end
  end

  def subscribe_message(user_id, account_id)
    @user = User.find user_id
    @account = Account.find account_id
    mail to: @account.email, from: @user.email, subject: "You have a new Subscriber at #{app_name}!"
  end

  def question_message(question_id)
    @question = Question.find question_id
    mail to: @question.profile.account.email, from: @question.user.email, subject: 'Question'
  end

  def question_asker_notification(question_id)
    @question = Question.find question_id
    mail to: @question.user.email, from: "info@#{Figaro.env.domain}", subject: 'Question Successfully Submitted'
  end

  private

  def admin_email
    environments = { 'production' => "#{Figaro.env.domain}", 'staging' => "qa1-#{Figaro.env.domain}", 'staging2' => "qa2-#{Figaro.env.domain}" }
    "contact@#{environments[Rails.env] || 'example.com'}"
  end
end
