class AccountMailer < BaseMailer
  def welcome_email(account)
    @account = account
    email_with_name = "#{@account.profile.name} <#{@account.email}>"
    mail(to: email_with_name, subject: 'Your Powerful New Website is Ready!')
  end

  def donation_notification(account, donation)
    @account = account
    @donation = donation
    email_with_name = "#{@account.profile.name} <#{@account.email}>"
    mail(to: email_with_name, subject: 'New Donation Received!')
  end

  def donor_donation_notification(donation)
    @donation = donation
    mail(to: "#{donation.donor_name} <#{donation.donor_email}>", subject: 'Your donation is processing')
  end

  def profile_removal_notification(account, profile, removed)
    @account = account
    @profile = profile
    @account_removed = removed
    mail(to: @account.email, subject: 'Your account was disabled')
  end

  def support_message(params)
    @message = params[:message]
    email_with_name = "#{params[:name]} <#{params[:email]}>"
    mail(to: admin_email, from: email_with_name, subject: params[:subject]) do |format|
      format.html { render layout: false }
    end
  end

  def subscribe_message(user, account)
    @user = user
    @account = account
    mail to: account.email, from: @user.email, subject: "You have a new Subscriber at #{app_name}!"
  end

  def question_message(question)
    @question = question
    mail to: @question.profile.account.email, from: @question.user.email, subject: 'Question'
  end

  def question_asker_notification(question)
    @question = question
    mail to: @question.user.email, from: "info@#{Figaro.env.domain}", subject: 'Question Successfully Submitted'
  end

  private

  def admin_email
    environments = { 'production' => "#{Figaro.env.domain}", 'staging' => "qa1-#{Figaro.env.domain}", 'staging2' => "qa2-#{Figaro.env.domain}" }
    "contact@#{environments[Rails.env] || 'example.com'}"
  end
end
