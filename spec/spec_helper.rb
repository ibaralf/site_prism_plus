require "rspec"
require "bundler/setup"
require "site_prism_plus"
require "selenium-webdriver"
require "capybara/rspec"
require "capybara/dsl"
#require "pry"
#require_relative '../lib/site_prism_plus/page.rb'
#require_relative '../lib/site_prism_plus/section.rb'

RSpec.configure do |config|
  include Capybara::RSpecMatchers
  config.color=true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end

module CapybaraHelper

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.javascript_driver = :chrome
  #Capybara.wait_on_first_by_default = true
  Capybara.configure do |config|
    config.default_max_wait_time = 5 # seconds
    config.default_driver        = :chrome
  end

end
