class DomainNameFetcher
  def initialize(request)
    @request = request
  end

  def fetch
    if built_in?
      subdomain_name if valid_subdomain_name?
    else
      domain_name
    end
  end

  private

  def valid_subdomain_name?
    !DomainFormatValidator::RESERVED_NAMES.include?(subdomain_name) &&
      domain_name != 'ngrok.io'
  end

  def built_in?
    domain_name.present? &&
      (domain_name == Figaro.env.domain ||
       domain_name.ends_with?(".#{Figaro.env.domain}") ||
       %w[ngrock.io localhost.ssl].include?(domain_name))
  end

  def domain_name
    @request.domain
  end

  def subdomain_name
    @request.subdomain
  end
end
