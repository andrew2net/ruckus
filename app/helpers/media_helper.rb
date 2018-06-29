module MediaHelper
  def wrap_with_submit_buttons
    render 'account/shared/media/submit_button', classes: 'top', text: 'Save' unless current_account.media.empty?
    yield
    render 'account/shared/media/submit_button', text: 'Save' unless current_account.media.empty?
  end
end
