class Account::PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?
    successfully_sent?(resource)
    if resource.errors.empty?
      flash.delete(:alert)
      flash[:notice] = 'Password Reset Instructions Successfully Sent'
    else
      flash.delete(:notice)
      flash[:alert] = resource.errors.full_messages.join('<br/>').html_safe
    end
  end
end
