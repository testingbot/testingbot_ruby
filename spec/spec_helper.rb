require "testingbot"
require "webmock/rspec"

Dir[File.join(__dir__, "support", "**", "*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Unit specs run fully offline. Live integration specs (tagged :integration)
  # are allowed to reach the real API and require TB_KEY / TB_SECRET.
  config.before(:each) do |example|
    if example.metadata[:integration]
      WebMock.allow_net_connect!
    else
      WebMock.disable_net_connect!
    end
  end
end
