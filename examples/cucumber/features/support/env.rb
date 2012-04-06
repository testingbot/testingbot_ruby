require 'capybara'
require 'capybara/cucumber'
require 'rspec'
require 'selenium/webdriver'
require 'testingbot/cucumber'

TestingBot::config do |config|
	config[:desired_capabilities] = { :browserName => "firefox", :version => 9, :platform => "WINDOWS" }
end

Capybara.default_driver = :testingbot