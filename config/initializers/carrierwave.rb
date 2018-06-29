module OpenURI::Meta
  def original_filename
    base_uri.path.to_s.split('/').last
  end
end

CarrierWave.configure do |config|
  config.asset_host = ActionController::Base.asset_host
end
