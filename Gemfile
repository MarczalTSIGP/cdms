source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.2'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'mimemagic'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'rails', '~> 7.0.5'
gem 'rqrcode', '~> 2.0'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 5.0'

gem 'active_link_to'
# gem 'activerecord-postgres_enum', git: 'https://github.com/dmarczal/activerecord-postgres_enum.git'
gem 'activerecord-postgres_enum'
gem 'breadcrumbs_on_rails'
gem 'carrierwave', '~> 2.1'
gem 'cpf_cnpj'
gem 'devise'
gem 'font-awesome-sass', '~> 5.13.0'
gem 'kaminari'
gem 'psych', '< 4'
gem 'rails-i18n', '~> 7.0.0'
gem 'root_domain'
gem 'simple_form'
gem 'sprockets-rails', git: 'https://github.com/rails/sprockets-rails.git'
gem 'validators'
gem 'whenever', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'

  gem 'guard'
  gem 'guard-minitest'
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', '~> 5.2.3'
  gem 'bullet', '~> 7.0.2'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rails', require: false
  gem 'rubycritic', require: false
end

group :test do
  gem 'capybara', '>= 3.38.0'
  gem 'selenium-webdriver'
  gem 'webdrivers', require: false

  gem 'shoulda-context', '~> 2.0.0'
  gem 'shoulda-matchers', '~> 4.3.0'
  gem 'simplecov', '0.17.1', require: false
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
