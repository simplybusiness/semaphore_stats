require 'capybara/dsl'
require 'capybara-webkit'

Capybara::Webkit.configure do |config|
  config.allow_unknown_urls
  config.ignore_ssl_errors
end

include Capybara::DSL

Capybara.javascript_driver = :webkit
Capybara.current_driver = Capybara.javascript_driver
