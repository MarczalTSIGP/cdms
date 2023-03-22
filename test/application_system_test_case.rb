require 'test_helper'
require 'support/helpers/form'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ::Helpers::Form

  DRIVER = ENV['LAUNCH_BROWSER'] ? :chrome : :headless_chrome

  def self.chrome_options
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--no-default-browser-check')
    options.add_argument('--start-maximized')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options
  end

  driven_by :selenium, using: DRIVER, screen_size: [1280, 1024], options: {
    browser: :remote,    
    url: "http://#{ENV['SELENIUM_HOST']}:#{ENV['SELENIUM_PORT']}/wd/hub",
    options: chrome_options 
  }

  def setup
    Capybara.disable_animation = true
    Capybara.server_host = '0.0.0.0'
    Capybara.app_host = app_host
    super
  end

  private

  def app_host
    app = "http://#{ENV['TEST_APP_HOST']}"
    port = Capybara.current_session.server.port
    "#{app}:#{port}"
  end
end
