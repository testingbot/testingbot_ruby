module TestingBot
  # Base class for every error raised by this gem. Rescue +TestingBot::Error+
  # to catch any failure originating from the client.
  #
  # Instances carry the HTTP status (when the failure came from an HTTP
  # response) and the raw response body for diagnostics.
  class Error < StandardError
    attr_reader :http_status, :body

    def initialize(message = nil, http_status: nil, body: nil)
      @http_status = http_status
      @body = body
      super(message)
    end
  end

  # Network-level failure: connection refused/reset, DNS failure, or a
  # request that exceeded the configured open/read timeout.
  class ConnectionError < Error; end

  # The API returned a body that could not be parsed as JSON (e.g. an HTML
  # gateway/maintenance page) or an empty body where JSON was expected.
  class ParseError < Error; end

  # Any 4xx response that is not covered by a more specific subclass.
  class ClientError < Error; end

  # 401/403 — missing or invalid credentials, or an account lacking the
  # required permission.
  class AuthenticationError < ClientError; end

  # 404 — the requested resource does not exist or does not belong to you.
  class NotFoundError < ClientError; end

  # 429 — the account hit the API rate limit. +retry_after+ exposes the
  # server-provided Retry-After value (seconds) when present.
  class RateLimitError < ClientError
    attr_reader :retry_after

    def initialize(message = nil, http_status: nil, body: nil, retry_after: nil)
      @retry_after = retry_after
      super(message, http_status: http_status, body: body)
    end
  end

  # 5xx — the API encountered a server-side error.
  class ServerError < Error; end

  # A 2xx response whose JSON body carried an application-level
  # <tt>{"error": "..."}</tt> field.
  class ApiError < Error; end
end
