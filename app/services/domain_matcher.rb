class DomainMatcher
  def self.matches?(request)
    DomainNameFetcher.new(request).fetch.present?
  end
end
