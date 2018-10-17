require File.expand_path(File.dirname(__FILE__) + '/../lib/testingbot/api.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/testingbot.rb')
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :should
  end
end