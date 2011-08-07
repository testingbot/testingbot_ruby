require "testingbot/version"

module Selenium
  module Client

    module Protocol
      attr_writer :client_key, :client_secret
      
        def client_key
          if @client_key.nil?
            @client_key, @client_secret = get_testingbot_credentials
          end
          @client_key
        end
        
        def client_secret
          if @client_secret.nil?
            @client_key, @client_secret = get_testingbot_credentials
          end
          @client_secret
        end
        
        def get_testingbot_credentials
          if File.exists?(File.expand_path("~/.testingbot"))
            str = File.open(File.expand_path("~/.testingbot")) { |f| f.readline }.chomp
            str.split(':')
          else
            raise "Please run the testingbot install tool first"
          end
        end
        
        # add custom parameters for testingbot.com
        def http_request_for_testingbot(verb, args)
          data = http_request_for_original(verb, args)
          data << "&client_key=#{client_key}&client_secret=#{client_secret}"
        end
        
        alias http_request_for_original http_request_for
        alias http_request_for http_request_for_testingbot
    end
  end
end

module TestingBot
  class TestingBot::TestCase < Test::Unit::TestCase
    alias :run_teardown_old :run_teardown
    alias :handle_exception_old :handle_exception
    
    attr_accessor :exception
    
    def run_teardown
      client_key, client_secret = get_testingbot_credentials
      params = {
        "session_id" => browser.session_id,
        "client_key" => client_key,
        "client_secret" => client_secret,
        "status_message" => @exception,
        "success" => passed?,
        "name" => self.to_s,
        "kind" => 2
      }
      
      url = URI.parse('http://localhost:3000/hq')
      http = Net::HTTP.new(url.host, url.port)
      response = http.post(url.path, params.map { |k, v| "#{k.to_s}=#{v}" }.join("&"))
      run_teardown_old
    end #def run_teardown
    
    def handle_exception(e)
      @exception = e.to_s
      handle_exception_old(e)
    end
    
    def get_testingbot_credentials
      if File.exists?(File.expand_path("~/.testingbot"))
        str = File.open(File.expand_path("~/.testingbot")) { |f| f.readline }.chomp
        str.split(':')
      else
        raise "Please run the testingbot install tool first"
      end
    end
  end
end