# we create our own Selenium classes here to extend them with user credentials and config

require 'selenium/client'
require 'selenium/webdriver'
require 'selenium/webdriver/remote/http/persistent'

module TestingBot

  class SeleniumWebdriver

    attr_reader :config, :driver
    attr_accessor :session_id_backup

    def initialize(options = {})
      @options = TestingBot::get_config.options
      @options = @options.merge(options)

      http_client = ::Selenium::WebDriver::Remote::Http::Persistent.new
      http_client.timeout = 400
      @driver = ::Selenium::WebDriver.for(:remote, :url => "http://#{@options[:client_key]}:#{@options[:client_secret]}@#{@options[:host]}:#{@options[:port]}/wd/hub", :desired_capabilities => @options[:desired_capabilities], :http_client => http_client)
      http_client.timeout = 120
    end

    def method_missing(meth, *args)
      @driver.send(meth, *args)
    end

    def session_id
      @driver.send(:bridge).session_id
    end

    def stop
      @session_id_backup = session_id
      @driver.quit
    end
  end
end

# if selenium RC, add testingbot credentials to request
if defined?(Selenium) && defined?(Selenium::Client) && defined?(Selenium::Client::Protocol)
  module Selenium
    module Client
      module Protocol
          # add custom parameters for testingbot.com
          def http_request_for_testingbot(verb, args)
            data = http_request_for_original(verb, args)
            data << "&client_key=#{TestingBot.get_config[:client_key]}&client_secret=#{TestingBot.get_config[:client_secret]}" unless TestingBot.get_config[:client_key].nil?
          end

          begin
           alias http_request_for_original http_request_for
           alias http_request_for http_request_for_testingbot
         rescue
         end
      end
    end
  end
end

if defined?(Selenium) && defined?(Selenium::Client) && defined?(Selenium::Client::Base)
  module Selenium
    module Client
      module Base
        DEFAULT_OPTIONS = {
          :screenshot => true
        }
        
        alias :close_current_browser_session_old :close_current_browser_session
        alias :start_new_browser_session_old :start_new_browser_session
        alias :initialize_old :initialize
        
        attr_accessor :options
        attr_accessor :session_id_backup
        attr_accessor :extra
        attr_accessor :platform
        attr_accessor :version

        attr_reader :config
        
        def initialize(*args)
          @config = TestingBot::get_config
          @options = @config[:options] || {}
          
          if args[0].kind_of?(Hash)
            options = args[0]
            @platform = options[:platform] || "WINDOWS"
            @version  = options[:version]  if options[:version]
          end
          
          @options = DEFAULT_OPTIONS
          initialize_old(*args)
          @host = options[:host] || @config[:host]
          @port = options[:port] || @config[:port]
        end
        
        def close_current_browser_session
          @session_id_backup = @session_id
          close_current_browser_session_old
        end

        def session_id
          @session_id || @session_id_backup || ""
        end
        
        def start_new_browser_session(options={})
          options = @options.merge options
          options[:platform] = @platform
          options[:version] = @version unless @version.nil?
          start_new_browser_session_old(options)
        end
        
        def extra=(str)
          @extra = str
        end
        
        def options=(opts = {})
          @options = @options.merge opts
        end
      end
    end
  end
end