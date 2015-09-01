require 'json'
module TestingBot

  class Api

    VERSION = 1
    API_URL = "https://api.testingbot.com"

    attr_reader :config

    def initialize(opts = {})
      @config = TestingBot::Config.new(opts)
    end

    def get_user_info
      get("/user")
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

    def get_single_test(test_id)
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

    private

    def get(url)
      uri = URI(API_URL + '/v' + VERSION.to_s + url)
      req = Net::HTTP::Get.new(uri.request_uri)
      req.basic_auth @config[:client_key], @config[:client_secret]
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      parsed = JSON.parse(res.body)

      if !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def put(url, params = {})
      uri = URI(API_URL + '/v' + VERSION.to_s + url)
      req = Net::HTTP::Put.new(uri.request_uri)
      req.basic_auth @config[:client_key], @config[:client_secret]
      req.set_form_data(params)
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      parsed = JSON.parse(res.body)

      if !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def delete(url, params = {})
      uri = URI(API_URL + '/v' + VERSION.to_s + url)
      req = Net::HTTP::Delete.new(uri.request_uri)
      req.basic_auth @config[:client_key], @config[:client_secret]
      req.set_form_data(params)
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      parsed = JSON.parse(res.body)

      if !parsed["error"].nil? && !parsed["error"].empty?
        raise parsed["error"]
      end

      parsed
    end

    def post(url, params = {})
      url = URI.parse(API_URL + '/v' + VERSION + url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.basic_auth @config[:client_key], @config[:client_secret]
      response = http.post(url.path, params.map { |k, v| "#{k.to_s}=#{v}" }.join("&"))
    end
  end
end
