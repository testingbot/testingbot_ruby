[![Build Status](https://travis-ci.org/testingbot/testingbot_ruby.png)](https://travis-ci.org/testingbot/testingbot_ruby)
[![Gem Version](https://badge.fury.io/rb/testingbot.svg)](https://badge.fury.io/rb/testingbot)

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

You'll need a [TestingBot account](https://testingbot.com).  TestingBot offers free trials.

## Setup

Once you have a TestingBot account, you can retrieve your unique TestingBot Key and Secret from the [TestingBot dashboard](https://testingbot.com/members)

## Usage

```ruby
@api = TestingBot::Api.new(key, secret)
```

#### Environment variables
You can set these environment variables to authenticate with our API:

```bash
TB_KEY=Your TestingBot Key
TB_SECRET=Your TestingBot Secret
```

### get_browsers
Gets a list of browsers you can test on

```ruby
@api.get_browsers
```

### get_user_info
Gets your user information

```ruby
@api.get_user_info
```

### update_user_info
Updates your user information

```ruby
@api.update_user_info({ "first_name" => 'my name' })
```

### update_test
Updates a Test with Meta-data to display on TestingBot.
For example, you can specify the test name and whether the test succeeded or failed:

```ruby
@api.update_test(webdriver_session_id, { :name => new_name, :success => true })
```

### get_test
Gets meta information for a test/job by passing in the WebDriver sessionID of the test you ran on TestingBot:

```ruby
@api.get_test(webdriver_session_id)
```

### get_tests
Gets a list of previous jobs/tests that you ran on TestingBot, order by last run:

```ruby
@api.get_tests(0, 10)
```

### delete_test
Deletes a test from TestingBot

```ruby
@api.delete_test(webdriver_session_id)
```

### stop_test
Stops a running test on TestingBot

```ruby
@api.stop_test(webdriver_session_id)
```

### get_builds
Gets a list of builds that you ran on TestingBot, order by last run:

```ruby
@api.get_builds(0, 10)
```

### get_build
Gets a build from TestingBot

```ruby
@api.get_build(build_identifier)
```

### get_tunnels
Gets a list of active tunnels for your account.

```ruby
@api.get_tunnels
```

### upload_local_file
Uploads a local file (APK or IPA file) to TestingBot Storage for Mobile App Testing.

```ruby
@api.upload_local_file(localFilePath)
```

### upload_remote_file
Uploads a remote file (APK or IPA URL) to TestingBot Storage for Mobile App Testing.

```ruby
@api.upload_remote_file(remoteFileUrl)
```

### get_uploaded_files
Retrieves files previously uploaded TestingBot Storage for Mobile App Testing.

```ruby
@api.get_uploaded_files(offset = 0, count = 30)
```

### get_uploaded_file
Retrieves meta-data for a file previously uploaded to TestingBot Storage.

```ruby
@api.get_uploaded_file(app_url)
```

### upload_remote_file
Uploads a remote file (APK or IPA URL) to TestingBot Storage for Mobile App Testing.

```ruby
@api.upload_remote_file(remoteFileUrl)
```
### get_authentication_hash
Calculates the hash necessary to share tests with other people

```ruby
@api.get_authentication_hash(identifier)
```

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

