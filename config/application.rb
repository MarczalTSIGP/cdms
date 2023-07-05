require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cdms
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.

    config.active_support.cache_format_version = 7.0
    config.active_support.disable_to_s_conversion = true

    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = ['pt-BR']
    config.i18n.default_locale = :'pt-BR'
    config.time_zone = 'America/Sao_Paulo'

    ENV.update YAML.load_file('config/application.yml')[Rails.env]
  end
end
