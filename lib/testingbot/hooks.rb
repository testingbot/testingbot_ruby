# rspec 1
if defined?(Spec) && defined?(Spec::VERSION::MAJOR) && Spec::VERSION::MAJOR == 1
  require "selenium/rspec/spec_helper"
  Spec::Runner.configure do |config|
    config.before(:suite) do
      if TestingBot.get_config[:require_tunnel]
        @@tunnel = TestingBot::Tunnel.new(TestingBot.get_config[:tunnel_options] || {})
        @@tunnel.start
      end
    end

    config.after(:suite) do
      @@tunnel.stop if defined? @@tunnel
    end

    config.prepend_after(:each) do
      client_key = TestingBot.get_config[:client_key]
      client_secret = TestingBot.get_config[:client_secret]
      
      if !client_key.nil?
        
        session_id = nil
        
        if !@selenium_driver.nil?
          session_id = @selenium_driver.session_id_backup
        elsif defined?(Capybara)
          begin
            if page.driver.browser.respond_to?(:session_id)
              session_id = page.driver.browser.session_id
            else
              session_id = page.driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
            end
          rescue Exception => e
            puts "Could not determine sessionID, can not send results to TestingBot.com #{e.message}"
          end
        end
        
        if !session_id.nil?
          api = TestingBot::Api.new
          params = {
            "session_id" => session_id,
            "status_message" => @execution_error,
            "success" => !actual_failure? ? 1 : 0,
            "name" => description.to_s,
            "kind" => 2
          }

          data = api.update_test(session_id, params)

          if ENV['JENKINS_HOME'] && (TestingBot.get_config[:jenkins_output] == true)
            puts "TestingBotSessionID=" + session_id
          end
        end
      else
          puts "Can't post test results to TestingBot since I could not a .testingbot file in your home-directory."
      end
    end
  end
end

# rspec 2
begin
  require 'rspec'

  ::RSpec.configuration.before :suite do
    if TestingBot.get_config[:require_tunnel]
      @@tunnel = TestingBot::Tunnel.new(TestingBot.get_config[:tunnel_options] || {})
      @@tunnel.start
    end
  end

  ::RSpec.configuration.after :suite do
    @@tunnel.stop if defined? @@tunnel
  end
  
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
          if page.driver.browser.respond_to?(:session_id)
            session_id = page.driver.browser.session_id
          else
            session_id = page.driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
          end
        rescue Exception => e
          p "Could not determine sessionID, can not send results to TestingBot.com #{e.message}"
        end
      end
      
      if !session_id.nil?
        if ENV['JENKINS_HOME'] && (TestingBot.get_config[:jenkins_output] == true)
          puts "TestingBotSessionID=" + session_id
        end
        api = TestingBot::Api.new
        params = {
            "session_id" => session_id,
            "status_message" => status_message,
            "success" => example.exception.nil? ? 1 : 0,
            "name" => test_name,
            "kind" => 2
        }

        data = api.update_test(session_id, params)
      end
    else
      puts "Can't post test results to TestingBot since I could not a .testingbot file in your home-directory."
    end
  end
rescue LoadError
end

if defined?(Test::Unit::TestCase)
  module TestingBot
    class TestingBot::TestCase < Test::Unit::TestCase
      
      attr_accessor :exception
      
      def run_teardown
        client_key = TestingBot.get_config[:client_key]
        client_secret = TestingBot.get_config[:client_secret]
        
        api = TestingBot::Api.new
        params = {
            "session_id" => browser.session_id,
            "status_message" => @exception,
            "success" => passed?,
            "name" => self.to_s,
            "kind" => 2,
            "extra" => browser.extra
        }

        data = api.update_test(session_id, params)

        if ENV['JENKINS_HOME'] && (TestingBot.get_config[:jenkins_output] == true)
          puts "TestingBotSessionID=" + browser.session_id
        end
        run_teardown_old
      end
      
      def handle_exception(e)
        @exception = e.to_s
        handle_exception_old(e)
      end
      
      alias :run_teardown_old :run_teardown
      alias :handle_exception_old :handle_exception
    end
  end
end