VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('spec', 'fixtures', 'vcr')
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
end

RSpec.configure do |c|
  c.around(:each) do |example|
    cassette_name = example.metadata[:cassette_name]
    cassette_name = :other unless cassette_name.present?

    VCR.use_cassette cassette_name, match_requests_on: [:host, :path], record: :new_episodes do
      example.call
    end
  end
end
