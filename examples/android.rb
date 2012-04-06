#!/usr/bin/env ruby
require "rubygems"
require File.expand_path(File.dirname(__FILE__) + '/../lib/testingbot/config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/testingbot/selenium.rb')

TestingBot::config do |config|
	config[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.android
end

driver = TestingBot::SeleniumWebdriver.new

driver.navigate.to "http://testingbot.com/"
puts driver.title
driver.quit