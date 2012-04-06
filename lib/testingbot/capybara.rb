require 'capybara'
require 'testingbot/config'
require 'testingbot/tunnel'
require 'capybara/dsl'

@tunnel = nil

module TestingBot
	module Capybara

		def start_tunnel
			return @tunnel unless @tunnel.nil?

			@tunnel = TestingBot::Tunnel.new
			@tunnel.start
		end

		class CustomDriver < ::Capybara::Selenium::Driver
			  def browser
			    unless @browser
			      if TestingBot.get_config[:need_tunnel]
			      	TestingBot::Capybara.start_tunnel
			      end

			      @browser = TestingBot::SeleniumWebdriver.new

			      main = Process.pid
			      at_exit do
			        @browser.quit if @browser
			        if TestingBot.get_config[:need_tunnel]
				      	@tunnel.stop unless @tunnel.nil?
				    end
			      end
			    end
			    @browser
			  end
		end
	end
end

Capybara.register_driver :testingbot do |app|
  TestingBot::Capybara::CustomDriver.new(app)
end