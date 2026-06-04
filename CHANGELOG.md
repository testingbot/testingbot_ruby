# Changelog

## 1.0.0

### Breaking changes

- **Errors are now wrapped in a `TestingBot::Error` hierarchy.** Methods previously
  leaked raw `RestClient` exceptions (`RestClient::Unauthorized`, `RestClient::NotFound`,
  …) and raised a bare `String` for in-body API errors. They now raise
  `TestingBot::AuthenticationError`, `TestingBot::NotFoundError`,
  `TestingBot::RateLimitError`, `TestingBot::ClientError`, `TestingBot::ServerError`,
  `TestingBot::ApiError`, `TestingBot::ParseError` or `TestingBot::ConnectionError`
  (all subclasses of `TestingBot::Error`, carrying `#http_status` and `#body`).
  Update any `rescue RestClient::...` clauses accordingly.
- The gem module is now consistently `TestingBot` (was split between `TestingBot` and
  `Testingbot`). `TestingBot::VERSION` holds the gem version.

### Fixed

- `get_authentication_hash` no longer raises `NameError` — `digest` is now required.
- `~/.testingbot` credentials are split on the first `:` only, so secrets containing a
  colon are no longer truncated.
- Path segments (IDs, session IDs, …) are URL-encoded; `upload_remote_file` and
  `create_user_in_team` no longer post to trailing-slash paths.
- `upload_local_file` no longer leaks a file descriptor and shares the versioned URL and
  error handling with the other requests.
- `update_*` / `delete_*` / `stop_test` return a real boolean instead of `nil` when the
  response omits a `success` key.

### Added — reliability

- Configurable open/read timeouts on every request (defaults 10s / 30s).
- Automatic retries with exponential backoff + jitter for idempotent requests on
  transient failures (timeouts, 5xx) and 429 (honoring `Retry-After`). POSTs are not
  auto-retried.
- Non-JSON and empty response bodies are handled gracefully.
- Debug output redacts secret-bearing fields.

### Added — API coverage (parity with the Java SDK)

- `get_job`
- `get_tunnel`, and a no-argument `delete_tunnel`
- `get_device`, server-side filtering on `get_devices`, `get_ip_ranges`
- `get_user_keys`, `get_user_client_key`
- optional filters on `get_tests`
- Full Codeless **Lab tests** surface (`get_lab_tests`, `create_lab_test`, `get_lab_test`,
  `update_lab_test`, `delete_lab_test`, steps, browsers, alert, report, schedule, trigger,
  stop, `trigger_all_lab_tests`)
- Full Codeless **Lab suites** surface (`get_lab_suites`, `create_lab_suite`,
  `get_lab_suite`, `delete_lab_suite`, tests, browsers, trigger)
- `update_local_file` / `update_remote_file` (replace a stored app binary)

### Changed — internals & tooling

- Transport extracted into `TestingBot::Connection` (a single `request` method,
  dependency-injectable for testing) behind the unchanged `TestingBot::Api` surface.
- New offline, mocked unit suite (WebMock) under `spec/unit`; the live suite under
  `spec/integration` is tagged `:integration` and runs only with credentials.
  `rake unit` is the default and CI gate; `rake integration` runs the live suite.
- `bin/testingbot` validates input, reads the secret without echoing it, and writes the
  credentials file with `0600` permissions.
