require 'capybara'
require 'testingbot/config'
require 'testingbot/tunnel'
require 'testingbot/selenium'
require 'capybara/dsl'

@tunnel = nil

module TestingBot
  module Capybara

    def self.start_tunnel
      return @tunnel unless @tunnel.nil?

      @tunnel = TestingBot::Tunnel.new(TestingBot.get_config[:tunnel_options] || {})
      @tunnel.start
    end

    class CustomDriver < ::Capybara::Selenium::Driver

        def session_id
          @browser.session_id
        end

        def browser
          unless @browser
            if TestingBot.get_config[:require_tunnel]
              TestingBot::Capybara.start_tunnel
            end

            @browser = TestingBot::SeleniumWebdriver.new(@options || {})

            main = Process.pid
            at_exit do
              if @browser
                begin
                  @browser.quit 
                rescue
                end
              end
              if TestingBot.get_config[:require_tunnel]
                @tunnel.stop unless @tunnel.nil?
              end
            end
          end
          @browser
        end
    end
  end
end

module Capybara
  class Session
    def stop
      driver.quit
    end

    def session_id
      driver.session_id
    end
  end
end

Capybara.register_driver :testingbot do |app|
  TestingBot::Capybara::CustomDriver.new(app)
end