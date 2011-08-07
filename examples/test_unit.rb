require "rubygems"
gem "selenium-client"
require "selenium/client"
gem 'test-unit'
require 'test/unit'

gem "testingbot"
require "testingbot"

class ExampleTest < TestingBot::TestCase
  attr_reader :browser

  def setup
    @browser = Selenium::Client::Driver.new \
        :host => "localhost", 
        :port => 4444, 
        :browser => "*safari", 
        :url => "http://www.google.com", 
        :timeout_in_second => 60

    browser.start_new_browser_session
  end

  def teardown
    browser.close_current_browser_session
  end

  def test_page_search
    browser.open "/"
    assert_equal "Google", browser.title
  end
end
