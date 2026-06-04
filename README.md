[![Gem Version](https://badge.fury.io/rb/testingbot.svg)](https://badge.fury.io/rb/testingbot)
[![Test Changes](https://github.com/testingbot/testingbot_ruby/actions/workflows/test.yml/badge.svg)](https://github.com/testingbot/testingbot_ruby/actions/workflows/test.yml)

# Testingbot-Ruby

This is the TestingBot Ruby client which makes it easy to
interact with the [TestingBot API](https://testingbot.com/support/api)

## Installation

Add this line to your application's Gemfile:

    gem 'testingbot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install testingbot


## Configuration

You'll need a [TestingBot account](https://testingbot.com). TestingBot offers free trials.
Once you have an account, retrieve your unique TestingBot Key and Secret from the
[TestingBot dashboard](https://testingbot.com/members).

```ruby
@api = TestingBot::Api.new(key, secret)
```

### Credential resolution

If you do not pass a key/secret explicitly, the client resolves them in this order
(the first source that provides both wins):

1. Arguments passed to `TestingBot::Api.new(key, secret)`
2. The `~/.testingbot` file — a single line in the form `key:secret`
3. The `TESTINGBOT_KEY` / `TESTINGBOT_SECRET` environment variables
4. The `TB_KEY` / `TB_SECRET` environment variables

```bash
# environment variable style
export TB_KEY=your-testingbot-key
export TB_SECRET=your-testingbot-secret
```

You can generate the `~/.testingbot` file interactively with the bundled CLI:

```bash
$ testingbot
```

The file is created with `0600` permissions; the client warns if it finds the file
readable by other users.

### Options

`TestingBot::Api.new` accepts an options hash as a third argument:

```ruby
@api = TestingBot::Api.new(key, secret,
  debug:        true,  # log (redacted) responses to STDERR
  open_timeout: 10,    # seconds to wait for the connection (default 10)
  read_timeout: 30,    # seconds to wait for the response   (default 30)
  max_retries:  3      # retry budget for idempotent requests (default 3)
)
```

Idempotent requests (GET/PUT/DELETE) are retried with exponential backoff on transient
failures (timeouts, 5xx, and 429 — honoring `Retry-After`). POST requests are never
retried automatically, to avoid duplicating side effects.

### Error handling

All failures raise a subclass of `TestingBot::Error`, which carries `#http_status` and
`#body`:

| Exception | Raised when |
|-----------|-------------|
| `TestingBot::AuthenticationError` | 401 / 403 (bad credentials or insufficient permissions) |
| `TestingBot::NotFoundError`       | 404 |
| `TestingBot::RateLimitError`      | 429 (exposes `#retry_after`) |
| `TestingBot::ClientError`         | other 4xx |
| `TestingBot::ServerError`         | 5xx |
| `TestingBot::ApiError`            | a 200 response whose body contains an `error` field |
| `TestingBot::ParseError`          | a non-JSON / unparseable response body |
| `TestingBot::ConnectionError`     | network failure or timeout |

```ruby
begin
  @api.get_test(session_id)
rescue TestingBot::NotFoundError
  # ...
rescue TestingBot::Error => e
  warn "TestingBot API error (#{e.http_status}): #{e.message}"
end
```

Most methods return the parsed JSON response (a `Hash` or `Array`). The mutating helpers
`update_user_info`, `update_test`, `delete_test`, `stop_test` and `delete_uploaded_file`
return a `Boolean` indicating success.

## Usage

### get_user_info
Gets your user information.

```ruby
@api.get_user_info
```

### update_user_info
Updates your user information. Returns `true`/`false`.

```ruby
@api.update_user_info({ "first_name" => 'my name' })
```

### get_user_keys
Retrieves the API key/secret pair for the current account.

```ruby
@api.get_user_keys
```

### get_team
Gets info about the current team you belong to.

```ruby
@api.get_team
```

### get_users_in_team
Gets all users in your team.

```ruby
@api.get_users_in_team(offset = 0, count = 10)
```

### get_user_in_team
Get info about a specific user in your team.

```ruby
@api.get_user_in_team(user_id)
```

### get_user_client_key
Gets a specific team member's API client key. Requires ADMIN rights.

```ruby
@api.get_user_client_key(user_id)
```

### create_user_in_team
Add a user to your current team. You need to have ADMIN rights to do this.

```ruby
@api.create_user_in_team(user = {})
```

### update_user_in_team
Updates a specific user in your team.

```ruby
@api.update_user_in_team(user_id, user = {})
```

### reset_credentials
Resets the credentials for a specific user.

```ruby
@api.reset_credentials(user_id)
```

### get_browsers
Gets a list of browsers you can test on.

```ruby
@api.get_browsers
```

### get_devices
Gets a list of (physical) devices you can test on. Optionally filter by platform and/or web capability.

```ruby
@api.get_devices
@api.get_devices("android", true)
```

### get_available_devices
Gets a list of available (physical) devices you can test on.

```ruby
@api.get_available_devices
```

### get_device
Gets a single physical device by its numeric ID.

```ruby
@api.get_device(device_id)
```

### get_ip_ranges
Gets the IP ranges TestingBot tests originate from (useful for firewall allow-listing).

```ruby
@api.get_ip_ranges
```

### take_screenshots
Take screenshots for a specific URL on specific browsers.

```ruby
@api.take_screenshots(configuration)
```

### get_screenshots_history
Retrieve screenshots that were previously generated.

```ruby
@api.get_screenshots_history(offset = 0, count = 10)
```

### get_screenshots
Get screenshots from a specific id.

```ruby
@api.get_screenshots(screenshots_id)
```

### get_tests
Gets a list of previous jobs/tests that you ran on TestingBot, ordered by last run.
The optional `filters` hash accepts the API's `since`, `browser_id`, `group`, `build` and `skip_fields` params.

```ruby
@api.get_tests(0, 10)
@api.get_tests(0, 10, build: "my-build")
```

### get_test
Gets meta information for a test/job by passing in the WebDriver sessionID of the test you ran on TestingBot.

```ruby
@api.get_test(webdriver_session_id)
```

### update_test
Updates a Test with meta-data to display on TestingBot (e.g. name and pass/fail). Returns `true`/`false`.

```ruby
@api.update_test(webdriver_session_id, { :name => new_name, :success => true })
```

### delete_test
Deletes a test from TestingBot. Returns `true`/`false`.

```ruby
@api.delete_test(webdriver_session_id)
```

### stop_test
Stops a running test on TestingBot. Returns `true`/`false`.

```ruby
@api.stop_test(webdriver_session_id)
```

### get_builds
Gets a list of builds that you ran on TestingBot, ordered by last run.

```ruby
@api.get_builds(0, 10)
```

### get_build
Gets a build from TestingBot.

```ruby
@api.get_build(build_identifier)
```

### delete_build
Deletes a build from TestingBot.

```ruby
@api.delete_build(build_identifier)
```

### get_job
Polls the status/result of an asynchronous job (e.g. a Codeless Lab run started by a trigger endpoint).

```ruby
@api.get_job(job_id)
```

### get_tunnels
Gets a list of active tunnels for your account.

```ruby
@api.get_tunnels
```

### get_tunnel
Gets the active tunnel, or a specific tunnel by ID.

```ruby
@api.get_tunnel
@api.get_tunnel(tunnel_id)
```

### delete_tunnel
Deletes a tunnel by ID, or the active tunnel when called without an argument.

```ruby
@api.delete_tunnel(tunnel_identifier)
@api.delete_tunnel
```

### upload_local_file
Uploads a local file (APK or IPA file) to TestingBot Storage for Mobile App Testing.
This request uses a 600-second timeout to accommodate large uploads.

```ruby
@api.upload_local_file(localFilePath)
```

### upload_remote_file
Uploads a remote file (APK or IPA URL) to TestingBot Storage for Mobile App Testing.

```ruby
@api.upload_remote_file(remoteFileUrl)
```

### update_local_file / update_remote_file
Replaces the binary stored under an existing app key.

```ruby
@api.update_local_file(app_url, localFilePath)
@api.update_remote_file(app_url, remoteFileUrl)
```

### get_uploaded_files
Retrieves files previously uploaded to TestingBot Storage for Mobile App Testing.

```ruby
@api.get_uploaded_files(offset = 0, count = 10)
```

### get_uploaded_file
Retrieves meta-data for a file previously uploaded to TestingBot Storage.

```ruby
@api.get_uploaded_file(app_url)
```

### delete_uploaded_file
Deletes a previously uploaded file. Returns `true`/`false`.

```ruby
@api.delete_uploaded_file(app_url)
```

### Codeless Lab tests

```ruby
@api.get_lab_tests(offset = 0, count = 10)
@api.create_lab_test(params = {})
@api.get_lab_test(lab_test_id)
@api.update_lab_test(lab_test_id, params = {})
@api.delete_lab_test(lab_test_id)
@api.get_lab_test_steps(lab_test_id)
@api.set_lab_test_steps(lab_test_id, params = {})
@api.get_lab_test_browsers(lab_test_id)
@api.set_lab_test_browsers(lab_test_id, params = {})
@api.add_lab_test_alert(lab_test_id, params = {})
@api.update_lab_test_alert(lab_test_id, params = {})
@api.create_lab_test_report(lab_test_id, params = {})
@api.update_lab_test_report(lab_test_id, params = {})
@api.schedule_lab_test(lab_test_id, params = {})
@api.trigger_lab_test(lab_test_id, params = {})
@api.stop_lab_test(lab_test_id)
@api.trigger_all_lab_tests(params = {})
```

### Codeless Lab suites

```ruby
@api.get_lab_suites(offset = 0, count = 10)
@api.create_lab_suite(params = {})
@api.get_lab_suite(suite_id)
@api.delete_lab_suite(suite_id)
@api.get_lab_suite_tests(suite_id)
@api.add_lab_suite_tests(suite_id, params = {})
@api.remove_lab_suite_test(suite_id, test_id)
@api.get_lab_suite_browsers(suite_id)
@api.set_lab_suite_browsers(suite_id, params = {})
@api.trigger_lab_suite(suite_id, params = {})
```

### get_authentication_hash
Calculates the hash necessary to share private tests/builds with other people.
Returns `MD5("#{key}:#{secret}:#{identifier}")`.

```ruby
@api.get_authentication_hash(identifier)
```

## Development

```bash
bundle install
bundle exec rake unit         # offline, mocked unit suite (no credentials required)
bundle exec rake integration  # live suite, requires TB_KEY / TB_SECRET
```

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
