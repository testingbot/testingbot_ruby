require 'rspec'
require 'capybara/rspec'
require 'testingbot'
require 'testingbot/capybara'

TestingBot::config do |config|
	config[:desired_capabilities] = { :browserName => "firefox", :version => 9, :platform => "WINDOWS" }
	config[:options] = { :screenshot => false, :extra => "Some extra data" }
	#config.require_tunnel
end

describe "People", :type => :request do
	before :all do
		Capybara.current_driver = :testingbot
	    Capybara.app_host = "http://testingbot.com"
 	end

	it 'has a homepage with the word Selenium' do
		visit '/'
		page.should have_content('Selenium')
	end
end