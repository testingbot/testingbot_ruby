require "testingbot/version"
require "testingbot/config"
require "testingbot/selenium"

# rspec 1
begin
  require 'spec'
  require "selenium/rspec/spec_helper"
    Spec::Runner.configure do |config|
      config.prepend_after(:each) do
        client_key = TestingBot.get_config[:client_key]
        client_secret = TestingBot.get_config[:client_secret]
        
        if !client_key.nil?
          
          session_id = nil
          
          if !@selenium_driver.nil?
            session_id = @selenium_driver.session_id_backup
          elsif defined?(Capybara)
            begin
              session_id = page.driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
            rescue Exception => e
              p "Could not determine sessionID, can not send results to TestingBot.com #{e.message}"
            end
          end
          
          if !session_id.nil?
            params = {
              "session_id" => session_id,
              "client_key" => client_key,
              "client_secret" => client_secret,
              "status_message" => @execution_error,
              "success" => !actual_failure?,
              "name" => description.to_s,
              "kind" => 2,
              "extra" => @selenium_driver.extra
            }
        
            url = URI.parse('http://testingbot.com/hq')
            http = Net::HTTP.new(url.host, url.port)
            response = http.post(url.path, params.map { |k, v| "#{k.to_s}=#{v}" }.join("&"))
          end
        else
            puts "Can't post test results to TestingBot since I could not a .testingbot file in your home-directory."
        end
      end
    end
rescue LoadError
end

# rspec 2
begin
  require 'rspec'
  
  ::RSpec.configuration.after :each do
    
    client_key = TestingBot.get_config[:client_key]
    client_secret = TestingBot.get_config[:client_secret]
    
    if !client_key.nil?
      test_name = ""
      if example.metadata && example.metadata[:example_group]
        if example.metadata[:example_group][:description_args]
          test_name = example.metadata[:example_group][:description_args].join(" ")
        end
        
        if example.metadata[:description_args]
          test_name = test_name + " it " + example.metadata[:description_args].join(" ")
        end
      end
      
      status_message = ""
      status_message = example.exception.to_s if !example.exception.nil?
      
      session_id = nil
      
      if !@selenium_driver.nil?
        session_id = @selenium_driver.session_id_backup
      elsif defined?(Capybara)
        begin
          session_id = page.driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
        rescue Exception => e
          p "Could not determine sessionID, can not send results to TestingBot.com #{e.message}"
        end
      end
      
      if !session_id.nil?
        params = {
          "session_id" => session_id,
          "client_key" => client_key,
          "client_secret" => client_secret,
          "status_message" => status_message,
          "success" => example.exception.nil?,
          "name" => test_name,
          "kind" => 2
        }
      
        if @selenium_driver && @selenium_driver.extra
          params["extra"] = @selenium_driver.extra
        end
    
        url = URI.parse('http://testingbot.com/hq')
        http = Net::HTTP.new(url.host, url.port)
        response = http.post(url.path, params.map { |k, v| "#{k.to_s}=#{v}" }.join("&"))
      end
    else
      puts "Can't post test results to TestingBot since I could not a .testingbot file in your home-directory."
    end
  end
rescue LoadError
end

if defined?(Test::Unit::TestCase) && (Test::Unit::TestCase.respond_to?('run_teardown'))
  module TestingBot
    class TestingBot::TestCase < Test::Unit::TestCase
      alias :run_teardown_old :run_teardown
      alias :handle_exception_old :handle_exception
      
      attr_accessor :exception
      
      def run_teardown
        client_key = TestingBot.get_config[:client_key]
        client_secret = TestingBot.get_config[:client_secret]
        
        params = {
          "session_id" => browser.session_id,
          "client_key" => client_key,
          "client_secret" => client_secret,
          "status_message" => @exception,
          "success" => passed?,
          "name" => self.to_s,
          "kind" => 2,
          "extra" => browser.extra
        }
        
        url = URI.parse('http://testingbot.com/hq')
        http = Net::HTTP.new(url.host, url.port)
        response = http.post(url.path, params.map { |k, v| "#{k.to_s}=#{v}" }.join("&"))
        run_teardown_old
      end
      
      def handle_exception(e)
        @exception = e.to_s
        handle_exception_old(e)
      end
    end
  end
end