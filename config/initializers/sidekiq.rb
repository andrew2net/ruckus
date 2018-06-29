Sidekiq.configure_client do |config|
  config.redis = { namespace: "ruckus_#{Rails.env}" }

  unless Rails.env.test?
    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
    end
  end
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: "ruckus_#{Rails.env}" }

  unless Rails.env.test?
    config.server_middleware do |chain|
      chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
    end

    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
    end
  end
end

CardExpiryNotifier.perform_async
