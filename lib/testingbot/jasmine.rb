require 'jasmine'
require 'testingbot/tunnel'

module TestingBot
	module Jasmine

		class Driver < ::Jasmine::SeleniumDriver
			attr_reader :http_address, :driver, :browser

			def initialize(browser, http_address)
				tunnel = TestingBot::Tunnel.new(TestingBot.get_config[:tunnel_options] || {})
	   			tunnel.start

				@browser = browser
				@http_address = http_address
				@driver = TestingBot::SeleniumWebdriver.new({ :browserName => browser, :name => "Jasmine Test" })
			end
		end
	end
end

module Jasmine
	class Config
		def start
			@client = TestingBot::Jasmine::Driver.new(browser, "#{jasmine_host}:3001/")
			@client.connect
		end
	end
end