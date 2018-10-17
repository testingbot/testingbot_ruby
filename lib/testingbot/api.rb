require 'json'
module TestingBot

  class Api

    VERSION = 1
    API_URL = "https://api.testingbot.com"

    attr_reader :key, :secret, :options

    def initialize(key = nil, secret = nil, options = {})
      @key = key
      @secret = secret
      @options = {
        :debug => false
      }.merge(options)
      if @key.nil? || @secret.nil?
        cached_credentials = load_config_file
        @key, @secret = cached_credentials unless cached_credentials.nil?
      end

      if @key.nil? || @secret.nil?
        @key = ENV["TB_KEY"] if ENV["TB_KEY"]
        @secret = ENV["TB_SECRET"] if ENV["TB_SECRET"]
      end

      raise "Please supply a TestingBot Key" if @key.nil?
      raise "Please supply a TestingBot Secret" if @secret.nil?
    end

    def get_user_info
      get("/user")
    end

    def get_browsers
      get("/browsers")
    end

    def update_user_info(params = {})
      new_params = {}
      params.keys.each do |key|
        new_params["user[#{key}]"] = params[key]
      end
      response = put("/user", new_params)
      response["success"]
    end

    def get_tests(offset = 0, count = 10)
      get("/tests?offset=#{offset}&count=#{count}")
    end

    def get_test(test_id)
      get("/tests/#{test_id}")
    end

    def update_test(test_id, params = {})
      new_params = {}
      params.keys.each do |key|
        new_params["test[#{key}]"] = params[key]
      end
      response = put("/tests/#{test_id}", new_params)
      response["success"]
    end

    def delete_test(test_id)
      response = delete("/tests/#{test_id}")
      response["success"]
    end

    def stop_test(test_id)
      response = put("/tests/#{test_id}/stop")
      response["success"]
    end

    def get_builds(offset = 0, count = 10)
      get("/builds?offset=#{offset}&count=#{count}")
    end

    def get_build(build_identifier)
      get("/builds/#{build_identifier}")
    end

    def get_tunnels
      get("/tunnel/list")
    end

    def get_authentication_hash(identifier)
      Digest::MD5.hexdigest("#{@key}:#{@secret}:#{identifier}")
    end

    private

    def load_config_file
      is_windows = false

      begin
        require 'rbconfig'
        is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
      rescue
        is_windows = (RUBY_PLATFORM =~ /w.*32/) || (ENV["OS"] && ENV["OS"] == "Windows_NT")
      end
      
      if is_windows
        config_file = "#{ENV['HOMEDRIVE']}\\.testingbot"
      else
        config_file = File.expand_path("#{Dir.home}/.testingbot")
      end
      
      if File.exists?(config_file)
        str = File.open(config_file) { |f| f.readline }.chomp
        return str.split(':')
      end
      
      return nil
    end

    def get(url)
      uri = URI(API_URL + '/v' + VERSION.to_s + url)
      req = Net::HTTP::Get.new(uri.request_uri)
      req.basic_auth @key, @secret
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      parsed = JSON.parse(res.body)
      p parsed if @options[:debug]
      
      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end
      parsed
    end

    def put(url, params = {})
      uri = URI(API_URL + '/v' + VERSION.to_s + url)
      req = Net::HTTP::Put.new(uri.request_uri)
      req.basic_auth @key, @secret
      req.set_form_data(params)
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      parsed = JSON.parse(res.body)
      p parsed if @options[:debug]

      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def delete(url, params = {})
      uri = URI(API_URL + '/v' + VERSION.to_s + url)
      req = Net::HTTP::Delete.new(uri.request_uri)
      req.basic_auth @key, @secret
      req.set_form_data(params)
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      parsed = JSON.parse(res.body)

      p parsed if @options[:debug]

      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def post(url, params = {})
      url = URI.parse(API_URL + '/v' + VERSION + url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.basic_auth @key, @secret
      res = http.post(url.path, params.map { |k, v| "#{k.to_s}=#{v}" }.join("&"))
      parsed = JSON.parse(res.body)

      p parsed if @options[:debug]

      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end
  end
end
