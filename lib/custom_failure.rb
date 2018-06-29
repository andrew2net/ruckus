class CustomFailure < Devise::FailureApp
  def redirect_url
    url = scope.eql?(:admin) ? new_admin_session_url : root_path(show_login_popup: true)
    url = url.split('sidekiq').last if url.include?('sidekiq')

    url
  end

  def respond
    http_auth? ? http_auth : redirect
  end
end
