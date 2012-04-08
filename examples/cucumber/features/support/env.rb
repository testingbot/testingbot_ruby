require 'capybara'
require 'capybara/cucumber'
require 'rspec'
require 'selenium/webdriver'
require 'testingbot/cucumber'

unless ENV['SELENIUM_BROWSERNAME'].nil?
	TestingBot::config do |config|
		config[:desired_capabilities] = { :browserName => ENV['SELENIUM_BROWSERNAME'], :version => ENV['SELENIUM_BROWSERVERSION'], :platform => ENV['SELENIUM_BROWSERPLATFORM'] }
	end
end

Capybara.default_driver = :testingbot