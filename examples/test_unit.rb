require 'rubygems'
require 'test/unit'
require "selenium/client"
require 'testingbot'

class ExampleTest < TestingBot::TestCase
  attr_reader :browser

  def setup
    @browser = Selenium::Client::Driver.new \
        :host => "hub.testingbot.com",
        :port => 4444, 
        :browser => "firefox", 
        :platform => "WINDOWS",
        :version => "10",
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
