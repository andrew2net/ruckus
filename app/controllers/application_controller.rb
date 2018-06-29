class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_devise_params, if: :devise_controller?
  before_action :enable_http_auth, if: :use_http_auth?

  alias_method :current_user, :current_account #for CanCanCan

  rescue_from CanCan::AccessDenied do
    flash[:error] = 'Access denied.'
    redirect_to profile_root_path
  end

  rescue_from ActionView::MissingTemplate do
    raise ActionController::RoutingError.new('Not Found')
  end

  def profile_path(domain_or_profile)
    domain = domain_or_profile.is_a?(Profile) ? domain_or_profile.domain : domain_or_profile
    return if domain.nil?

    if domain.internal?
      root_url(subdomain: domain.name, host: Figaro.env.domain)
    else
      uri = URI.parse(root_url)
      uri.host = domain.name
      uri.to_s
    end
  end

  def field_is_active?(check_against, check_value)
    check_against.present? && check_against.include?(check_value)
  end
  helper_method :field_is_active?

  def configure_devise_params
    candidate_profile_attributes = [:first_name, :last_name, :phone, :office]
    organization_profile_attributes = [:name, :phone]
    profile_attributes = (candidate_profile_attributes + organization_profile_attributes).uniq


    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation,
               candidate_profile_attributes:    candidate_profile_attributes,
               organization_profile_attributes: organization_profile_attributes,
               profile_attributes:              profile_attributes)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:email, :password, :password_confirmation, :current_password,
               candidate_profile_attributes:    candidate_profile_attributes,
               organization_profile_attributes: organization_profile_attributes,
               profile_attributes:              profile_attributes)
    end
  end

  def request_hash
    result = {}
    REQUEST_METHODS.each do |method|
      result[method] = request.send(method).to_s
    end
    result
  end

  def enable_http_auth
    credentials = { name: 'ruck.us', password: 'secret123!' }

    authenticate_or_request_with_http_basic(credentials[:realm] || 'Application') do |name, password|
      name == credentials[:name] && password == credentials[:password]
    end
  end

  def use_http_auth?
    (Rails.env.staging? || Rails.env.staging2?) && controller_name != 'donations' && action_name != 'create'
  end

  def mixpanel_tracker(account = current_account)
    @mixpanel_tracker ||= MixpanelTracker.new(account)
  end

  def current_profile
    current_account.profile.decorate(context: { account_editing: true })
  end
  helper_method :current_profile
end
