require 'cgi'
require 'uri'
require 'digest'
require 'json'

require 'testingbot/errors'
require 'testingbot/connection'

require 'testingbot/resources/user'
require 'testingbot/resources/team'
require 'testingbot/resources/platform'
require 'testingbot/resources/tests'
require 'testingbot/resources/builds'
require 'testingbot/resources/screenshots'
require 'testingbot/resources/tunnels'
require 'testingbot/resources/storage'
require 'testingbot/resources/jobs'
require 'testingbot/resources/lab'
require 'testingbot/resources/lab_suites'
require 'testingbot/resources/sharing'

module TestingBot
  # Ruby client for the TestingBot REST API (https://testingbot.com/support/api).
  #
  # Credentials are resolved, in order, from: explicit arguments, the
  # ~/.testingbot file, the TESTINGBOT_KEY/TESTINGBOT_SECRET environment
  # variables, then TB_KEY/TB_SECRET.
  #
  # Endpoint methods live in the TestingBot::Resources::* mixins (one per API
  # category) and are included below; they call the private get/post/put/delete
  # helpers and @connection. Transport (timeouts, retries, error handling) lives
  # in TestingBot::Connection; a custom connection can be injected via
  # options[:connection] for testing.
  class Api
    # Public API version used in the URL path (https://api.testingbot.com/v1/...).
    API_URL     = Connection::API_URL
    API_VERSION = Connection::API_VERSION
    # Deprecated alias kept for backward compatibility (this is the *API* version,
    # not the gem version — see TestingBot::VERSION for the gem version).
    VERSION = API_VERSION

    include Resources::User
    include Resources::Team
    include Resources::Platform
    include Resources::Tests
    include Resources::Builds
    include Resources::Screenshots
    include Resources::Tunnels
    include Resources::Storage
    include Resources::Jobs
    include Resources::Lab
    include Resources::LabSuites
    include Resources::Sharing

    attr_reader :key, :secret, :options

    def initialize(key = nil, secret = nil, options = {})
      @options = { :debug => false }.merge(options)
      @key     = key
      @secret  = secret
      resolve_credentials!

      raise "Please supply a TestingBot Key"    if @key.nil?
      raise "Please supply a TestingBot Secret" if @secret.nil?

      @connection = @options[:connection] ||
                    Connection.new(key: @key, secret: @secret, options: @options)
    end

    private

    def get(path)
      @connection.request(:get, path)
    end

    def post(path, params = {})
      @connection.request(:post, path, params)
    end

    def put(path, params = {})
      @connection.request(:put, path, params)
    end

    def delete(path, params = {})
      @connection.request(:delete, path, params)
    end

    # Wrap a flat hash under a bracketed prefix, e.g. wrap_params("test", name: "x")
    # => { "test[name]" => "x" } — the form encoding the Rails-style backend expects.
    def wrap_params(prefix, params)
      params.each_with_object({}) do |(key, value), memo|
        memo["#{prefix}[#{key}]"] = value
      end
    end

    # Build a "?a=1&b=2" query string from a hash, dropping nil values and
    # URL-encoding keys/values. Returns "" when nothing is left.
    def query(params)
      filtered = params.reject { |_, value| value.nil? }
      return "" if filtered.empty?
      "?" + URI.encode_www_form(filtered)
    end

    # URL-encode a path segment (numeric IDs, session IDs, etc.).
    def escape(value)
      CGI.escape(value.to_s)
    end

    # Strip the tb:// scheme from an app URL. The value targets a wildcard route,
    # so any remaining slashes are intentionally preserved (not escaped).
    def strip_scheme(app_url)
      app_url.to_s.gsub(%r{tb://}, '')
    end

    def success?(response)
      response.is_a?(Hash) ? !!response["success"] : false
    end

    def resolve_credentials!
      if @key.nil? || @secret.nil?
        cached = load_config_file
        @key, @secret = cached unless cached.nil?
      end

      if @key.nil? || @secret.nil?
        @key    = ENV["TESTINGBOT_KEY"]    if ENV["TESTINGBOT_KEY"]
        @secret = ENV["TESTINGBOT_SECRET"] if ENV["TESTINGBOT_SECRET"]
      end

      if @key.nil? || @secret.nil?
        @key    = ENV["TB_KEY"]    if ENV["TB_KEY"]
        @secret = ENV["TB_SECRET"] if ENV["TB_SECRET"]
      end
    end

    def load_config_file
      config_file = File.join(Dir.home, ".testingbot")
      return nil unless File.exist?(config_file)

      if insecure_permissions?(config_file)
        warn("TestingBot: #{config_file} is readable by other users; run `chmod 600 #{config_file}`")
      end

      str = File.open(config_file) { |f| f.readline }.chomp
      # Split on the first colon only, so a secret containing ':' is preserved.
      str.split(':', 2)
    end

    def insecure_permissions?(path)
      (File.stat(path).mode & 0o077) != 0
    rescue StandardError
      false
    end
  end
end
