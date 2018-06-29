module DomainsHelper
  def full_domain_url(domain)
    if domain.internal?
      "http://#{domain.name}.#{request.host_with_port}"
    else
      "http://#{domain.name}"
    end
  end
end
