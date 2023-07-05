Rails.application.config.action_mailer.default_url_options = { host: ENV.fetch('app.host', nil) }
Rails.application.routes.default_url_options[:host] = ENV.fetch('app.host', nil)
