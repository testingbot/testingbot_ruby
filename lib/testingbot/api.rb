require 'json'
require "rest-client"

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
        @key = ENV["TESTINGBOT_KEY"] if ENV["TESTINGBOT_KEY"]
        @secret = ENV["TESTINGBOT_SECRET"] if ENV["TESTINGBOT_SECRET"]
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

    def get_devices
      get("/devices")
    end

    def get_available_devices
      get("/devices/available")
    end

    def get_team
      get("/team-management")
    end

    def get_users_in_team(offset = 0, count = 10)
      get("/team-management/users?offset=#{offset}&count=#{count}")
    end

    def get_user_in_team(user_id)
      get("/team-management/users/#{user_id}")
    end

    def create_user_in_team(user = {})
      post("/team-management/users/", user)
    end

    def update_user_in_team(user_id, user = {})
      put("/team-management/users/#{user_id}", user)
    end

    def reset_credentials(user_id)
      post("/team-management/users/#{user_id}/reset-keys")
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

    def delete_build(build_identifier)
      delete("/builds/#{build_identifier}")
    end

    def take_screenshots(configuration)
      post("/screenshots", configuration)
    end

    def get_screenshots_history(offset = 0, count = 10)
      get("/screenshots?offset=#{offset}&count=#{count}")
    end

    def get_screenshots(screenshots_id)
      get("/screenshots/#{screenshots_id}")
    end

    def get_tunnels
      get("/tunnel/list")
    end

    def delete_tunnel(tunnel_identifier)
      delete("/tunnel/#{tunnel_identifier}")
    end

    def get_authentication_hash(identifier)
      Digest::MD5.hexdigest("#{@key}:#{@secret}:#{identifier}")
    end

    def upload_local_file(file_path)
      response = RestClient::Request.execute(
        method: :post,
        url: API_URL + "/v1/storage",
        user: @key,
        password: @secret,
        timeout: 600,
        payload: {
          multipart: true,
          file: File.new(file_path, 'rb')
        }
      )
      parsed = JSON.parse(response.body)
      parsed
    end

    def upload_remote_file(url)
      post("/storage/", {
        :url => url
      })
    end

    def get_uploaded_files(offset = 0, count = 10)
      get("/storage?offset=#{offset}&count=#{count}")
    end

    def get_uploaded_file(app_url)
      get("/storage/#{app_url.gsub(/tb:\/\//, '')}")
    end

    def delete_uploaded_file(app_url)
      response = delete("/storage/#{app_url.gsub(/tb:\/\//, '')}")
      response["success"]
    end

    private

    def load_config_file
      config_file = File.join(Dir.home, ".testingbot")
      
      if File.exist?(config_file)
        str = File.open(config_file) { |f| f.readline }.chomp
        return str.split(':')
      end
      
      return nil
    end

    def get(url)
      uri = API_URL + '/v' + VERSION.to_s + url

      response = RestClient::Request.execute method: :get, url: uri, user: @key, password: @secret
      parsed = JSON.parse(response.body)

      p parsed if @options[:debug]
      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def put(url, params = {})
      uri = API_URL + '/v' + VERSION.to_s + url

      response = RestClient::Request.execute method: :put, url: uri, payload: params, user: @key, password: @secret
      parsed = JSON.parse(response.body)

      p parsed if @options[:debug]
      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def delete(url, params = {})
      uri = API_URL + '/v' + VERSION.to_s + url
      response = RestClient::Request.execute method: :delete, url: uri, payload: params, user: @key, password: @secret
      parsed = JSON.parse(response.body)

      p parsed if @options[:debug]
      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def post(url, params = {})
      uri = API_URL + '/v' + VERSION.to_s + url

      response = RestClient::Request.execute method: :post, url: uri, payload: params, user: @key, password: @secret
      parsed = JSON.parse(response.body)

      p parsed if @options[:debug]
      if !parsed.is_a?(Array) && !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end
  end
end
