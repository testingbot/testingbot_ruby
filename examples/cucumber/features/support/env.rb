require 'capybara'
require 'capybara/cucumber'
require 'rspec'
require 'selenium/webdriver'
require 'testingbot/cucumber'

caps = Selenium::WebDriver::Remote::Capabilities.firefox  
caps.version = "8"  
caps.platform = :WINDOWS 

Capybara.default_driver = :testingbot
Capybara.register_driver :testingbot do |app|
	client = Selenium::WebDriver::Remote::Http::Default.new
		client.timeout = 120
  	Capybara::Selenium::Driver.new(app,
	    :browser => :remote,
	    :url => "http://key:secret@hub.testingbot.com:4444/wd/hub",
	    :http_client => client,
	    :desired_capabilities => caps)
end