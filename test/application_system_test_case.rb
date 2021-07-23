require 'test_helper'
require 'support/helpers/form'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ::Helpers::Form

  def self.args
    args = ['--no-default-browser-check', '--start-maximized']
    args << '--disable-dev-shm-usage'
    args << 'headless' unless ENV['LAUNCH_BROWSER']
    args
  end

  driven_by :selenium, using: :chrome, screen_size: [1280, 720], options: {
    url: "http://#{ENV['SELENIUM_HOST']}:#{ENV['SELENIUM_PORT']}/wd/hub",
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: args }
    )
  }

  def setup
    Capybara.disable_animation = true
    Capybara.server_host = '0.0.0.0'
    Capybara.app_host = app_host
    host! app_host
    super
  end

  private

  def app_host
    app = "http://#{ENV['TEST_APP_HOST']}"
    port = Capybara.current_session.server.port
    "#{app}:#{port}"
  end
end
