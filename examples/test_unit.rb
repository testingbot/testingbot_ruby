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
        :host => "hub.testingbot.com",
        :port => 4444, 
        :browser => "iexplore", 
        :platform => "WINDOWS",
        :version => "7",
        :url => "http://www.google.com", 
        :timeout_in_second => 60
      
    browser.extra = "First test" # some custom data you can pass with your tests
    
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
