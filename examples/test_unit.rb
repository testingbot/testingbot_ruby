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
        :host => "10.0.1.4", 
        :port => 4444, 
        :browser => "firefox", 
        :platform => "WINDOWS",
        :version => "6",
        :url => "http://www.google.com", 
        :timeout_in_second => 60
      
    browser.options = {
      :screenrecorder => false
    }
    
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
