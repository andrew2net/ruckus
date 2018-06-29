class Account::SessionsController < Devise::SessionsController
  skip_before_filter :require_no_authentication

  def new
    render 'new', layout: false
  end

  def create
    @account = Account.with_deleted.find_by(email: params[:account][:email])

    flash[:notice], flash[:alert] = nil

    if @account.present? && @account.valid_password?(params[:account][:password])
      if @account.active_for_authentication?
        @account.logins.create(data: request_hash)
        sign_in(:account, @account)
        flash[:notice] = 'Signed in successfully.'
      else
        @account = nil
        flash[:alert] = "The e-mail address with which you are trying to login is associated with a deactivated account. To re-activate your account (or to use this e-mail address to create a new account), you will need to send an <a href='mailto:support@ruck.us?subject=Help-with-deactivated-account'>e-mail message</a> to <a href='mailto:support@ruck.us?subject=Help-with-deactivated-account'>support@ruck.us</a>.".html_safe
      end
    else
      @account = nil
      flash[:alert] = 'Invalid email or password'
    end
  end
end
