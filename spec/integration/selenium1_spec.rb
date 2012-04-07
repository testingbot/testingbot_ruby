require "uri"
require "net/http"
require 'rspec'

@@success = true
@@check_api = true

::RSpec.configuration.after :each do
  if @@check_api
    api = TestingBot::Api.new
    single_test = api.get_single_test(@selenium_driver.session_id)
    single_test["success"].should eql(@@success)
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Selenium RC test" do

  before(:all) do
    @selenium_driver = Selenium::Client::Driver.new \
        :browser => "firefox", 
        :url => "http://testingbot.com", 
        :timeout_in_second => 60,
        :platform => "WINDOWS",
        :version => "10"
  end
  before(:each) do
    @selenium_driver.start_new_browser_session
  end

  after(:each) do
    @selenium_driver.close_current_browser_session
  end

  context "Connect and run successfully to the TestingBot Grid with Selenium 1 (RC)" do
    it "should be able to run an RC test successfully" do 
      @check_api = false
      @selenium_driver.open "/"
      @selenium_driver.text?("TestingBot").should be_true
    end
  end

  context "Check that we report the test status back successfully" do
    it "should send a success status to TestingBot upon success of the test" do
      @check_api = true
      @selenium_driver.open "/"
      @selenium_driver.text?("TestingBot").should be_true
    end
  end
end