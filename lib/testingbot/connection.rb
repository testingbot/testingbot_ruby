require 'json'
require 'rest-client'

require 'testingbot/errors'

module TestingBot
  # Transport layer for the TestingBot API.
  #
  # Owns the base URL, API version, credentials and HTTP client, and exposes a
  # single +request+ entry point that every endpoint goes through. Centralising
  # transport here means timeouts, retries/backoff, rate-limit handling, JSON
  # parsing, error mapping and debug redaction all live in one place.
  #
  # The HTTP client is injectable (+http:+) so the gem can be unit-tested
  # without real network access.
  class Connection
    API_URL     = "https://api.testingbot.com".freeze
    API_VERSION = 1

    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 30
    DEFAULT_MAX_RETRIES  = 3

    # Verbs safe to retry automatically. POST is excluded so we never replay a
    # side-effecting create/upload.
    IDEMPOTENT = [:get, :put, :delete].freeze

    # Transient failures worth retrying on idempotent verbs.
    RETRYABLE = [
      RestClient::RequestTimeout,        # 408
      RestClient::TooManyRequests,       # 429
      RestClient::InternalServerError,   # 500
      RestClient::BadGateway,            # 502
      RestClient::ServiceUnavailable,    # 503
      RestClient::GatewayTimeout,        # 504
      RestClient::Exceptions::Timeout,   # open/read timeout
      RestClient::ServerBrokeConnection,
      SocketError,
      Errno::ECONNRESET,
      Errno::ECONNREFUSED,
      Errno::EHOSTUNREACH,
      Errno::ETIMEDOUT
    ].freeze

    # Response keys whose values are redacted in debug output.
    REDACT_KEYS = %w[key secret api_key api_secret client_key token password].freeze

    def initialize(key:, secret:, options: {}, http: RestClient::Request)
      @key     = key
      @secret  = secret
      @options = options || {}
      @http    = http
    end

    # Execute an HTTP request and return the parsed JSON body.
    #
    # verb   - one of :get, :post, :put, :delete
    # path   - path after the version prefix, e.g. "/tests/123"
    # params - request payload (ignored for :get and for empty payloads)
    # opts   - per-call overrides, e.g. { timeout: 600 } for uploads
    def request(verb, path, params = {}, opts = {})
      idempotent = IDEMPOTENT.include?(verb)
      attempt = 0

      begin
        parse(execute(verb, path, params, opts))
      rescue *RETRYABLE => e
        attempt += 1
        if idempotent && attempt <= max_retries
          sleep(delay_for(e, attempt))
          retry
        end
        raise map_exception(e)
      rescue RestClient::ExceptionWithResponse => e
        raise map_exception(e)
      end
    end

    private

    def execute(verb, path, params, opts)
      args = {
        method:       verb,
        url:          build_url(path),
        user:         @key,
        password:     @secret,
        open_timeout: @options.fetch(:open_timeout, DEFAULT_OPEN_TIMEOUT),
        read_timeout: @options.fetch(:read_timeout, DEFAULT_READ_TIMEOUT)
      }
      args[:timeout] = opts[:timeout] if opts[:timeout]
      args[:payload] = params if verb != :get && !blank_payload?(params)
      @http.execute(**args)
    end

    def parse(response)
      body = response.body.to_s
      return {} if body.strip.empty?

      parsed = begin
        JSON.parse(body)
      rescue JSON::ParserError
        raise ParseError.new(
          "TestingBot API returned a non-JSON response (HTTP #{response.code}): #{body[0, 200]}",
          http_status: response.code, body: body
        )
      end

      log(parsed) if @options[:debug]

      if parsed.is_a?(Hash) && !parsed["error"].to_s.empty?
        raise ApiError.new(parsed["error"], http_status: response.code, body: body)
      end

      parsed
    end

    def build_url(path)
      "#{API_URL}/v#{API_VERSION}#{path}"
    end

    def blank_payload?(params)
      params.nil? || (params.respond_to?(:empty?) && params.empty?)
    end

    def max_retries
      @options.fetch(:max_retries, DEFAULT_MAX_RETRIES)
    end

    def delay_for(error, attempt)
      if error.is_a?(RestClient::TooManyRequests)
        seconds = retry_after(error)
        return [seconds, 120].min if seconds && seconds > 0
      end
      backoff(attempt)
    end

    # Exponential backoff (base 0.5s, doubling) with +/-20% jitter.
    def backoff(attempt)
      base   = 0.5 * (2**(attempt - 1))
      jitter = base * 0.2
      base + ((rand * 2) - 1) * jitter
    end

    def retry_after(error)
      headers = error.response && error.response.headers
      return nil unless headers
      (headers[:retry_after] || headers["Retry-After"]).to_i
    end

    def map_exception(error)
      case error
      when RestClient::Unauthorized, RestClient::Forbidden
        AuthenticationError.new(error.message, http_status: error.http_code, body: response_body(error))
      when RestClient::ResourceNotFound
        NotFoundError.new(error.message, http_status: error.http_code, body: response_body(error))
      when RestClient::TooManyRequests
        RateLimitError.new(error.message, http_status: error.http_code,
                           body: response_body(error), retry_after: retry_after(error))
      when RestClient::ExceptionWithResponse
        code = error.http_code
        klass = code && code >= 500 ? ServerError : ClientError
        klass.new(error.message, http_status: code, body: response_body(error))
      when RestClient::Exceptions::Timeout, SocketError, SystemCallError
        ConnectionError.new(error.message)
      else
        Error.new(error.message)
      end
    end

    def response_body(error)
      error.response && error.response.body
    rescue StandardError
      nil
    end

    def log(parsed)
      warn(redact(parsed).inspect)
    end

    def redact(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(k, v), memo|
          memo[k] = REDACT_KEYS.include?(k.to_s.downcase) ? "[REDACTED]" : redact(v)
        end
      when Array
        obj.map { |v| redact(v) }
      else
        obj
      end
    end
  end
end
