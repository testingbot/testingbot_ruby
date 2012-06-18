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

          begin
            data = api.update_test(session_id, params)
          rescue
          end
          
          if ENV['JENKINS_HOME'] && (TestingBot.get_config[:jenkins_output] == true)
            puts "TestingBotSessionID=" + session_id
          end
        end
      else
          puts "Can't post test results to TestingBot since I could not find a .testingbot file in your home-directory."
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

  module TestingBot
    module RSpecInclude
      attr_reader :selenium_driver
      alias_method :page, :selenium_driver

      def self.included(base)
        base.around do |test|
          if TestingBot.get_config.desired_capabilities.instance_of?(Array)
            TestingBot.get_config.desired_capabilities.each do |browser|

              if defined?(Capybara)
                ::Capybara.register_driver :multibrowser do |app|
                  TestingBot::Capybara::CustomDriver.new(app, { :desired_capabilities => browser })
                end

                @selenium_driver = ::Capybara::Session.new(:multibrowser)
              else
                @selenium_driver = TestingBot::SeleniumWebdriver.new({ :desired_capabilities => browser })
              end

              begin
                test.run
              ensure
                @selenium_driver.stop
              end
            end
          else
            if defined?(Capybara)
              @selenium_driver = ::Capybara::Session.new(:testingbot)
            else
              @selenium_driver = TestingBot::SeleniumWebdriver.new({ :desired_capabilities => TestingBot.get_config.desired_capabilities })
            end
            begin
              test.run
            ensure
              @selenium_driver.stop
            end
          end
        end
      end
    end  

    module RSpecIncludeLegacy
      attr_reader :selenium_driver
      alias_method :page, :selenium_driver

      def self.included(base)
        base.around do |test|
          if TestingBot.get_config.desired_capabilities.instance_of?(Array)
            TestingBot.get_config.desired_capabilities.each do |browser|
              @selenium_driver = ::Selenium::Client::Driver.new(:browser => browser[:browserName], :url => TestingBot.get_config[:browserUrl])
              @selenium_driver.start_new_browser_session(browser)
              begin
                test.run
              ensure
                @selenium_driver.stop
              end
            end
          else
            @selenium_driver = ::Selenium::Client::Driver.new(:browser => browser[:browserName], :url => TestingBot.get_config[:browserUrl])
            @selenium_driver.start_new_browser_session(TestingBot.get_config.desired_capabilities)
            begin
              test.run
            ensure
              @selenium_driver.stop
            end
          end
        end
      end
    end  
  end

  ::RSpec.configuration.include(TestingBot::RSpecIncludeLegacy, :multibrowserRC => true)
  ::RSpec.configuration.include(TestingBot::RSpecInclude, :multibrowser => true)

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
        session_id = @selenium_driver.session_id
      elsif defined? page
        begin
          if page.driver.browser.respond_to?(:session_id)
            session_id = page.driver.browser.session_id
          else
            session_id = page.driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
          end
        rescue Exception => e
          p "Could not determine sessionID, can not send results to TestingBot.com #{e.message}"
        end

        if session_id.nil? || session_id.empty?
          begin
            session_id = page.driver.browser.send(:bridge).session_id
          rescue
          end
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

        begin
          data = api.update_test(session_id, params)
        rescue
        end
      end
    else
      puts "Can't post test results to TestingBot since I could not find a .testingbot file in your home-directory."
    end
  end
rescue LoadError
end

module TestingBot
  module SeleniumForTestUnit
    attr_accessor :exception
    attr_reader :browser
    
    def run(*args, &blk)
      return if @method_name.to_s == "default_test"
      if TestingBot.get_config.desired_capabilities.instance_of?(Array)
        TestingBot.get_config.desired_capabilities.each do |browser|
          @browser = ::Selenium::Client::Driver.new(:browser => browser[:browserName], :url => TestingBot.get_config[:browserUrl])
          @browser.start_new_browser_session(browser)
          super(*args, &blk)
          @browser.stop
        end
      else
        super(*args, &blk)
      end
    end

    def teardown
      return super if @browser.nil?
      api = TestingBot::Api.new
      params = {
          "session_id" => @browser.session_id,
          "status_message" => @exception || "",
          "success" => passed? ? 1 : 0,
          "name" => self.to_s,
          "kind" => 2
      }

      begin
        data = api.update_test(@browser.session_id, params)
      rescue
      end

      if ENV['JENKINS_HOME'] && (TestingBot.get_config[:jenkins_output] == true)
        puts "TestingBotSessionID=" + @browser.session_id
      end
      super
    end
    
    def handle_exception(e)
      @exception = e.to_s
      handle_exception_old(e)
    end

    alias :handle_exception_old :handle_exception
  end
end

begin
  require 'test/unit/testcase'
  module TestingBot
    class TestCase < Test::Unit::TestCase
      include SeleniumForTestUnit
    end
  end
rescue LoadError
end

if defined?(ActiveSupport::TestCase)
  module TestingBot
    class RailsTestCase < ::ActiveSupport::TestCase
      include SeleniumForTestUnit
    end
  end
end