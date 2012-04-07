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


TestingBot::config do |config|
  config[:desired_capabilities] = { :browserName => "firefox", :version => 9, :platform => "WINDOWS" }
end

describe "Selenium WebDriver test" do

  before(:all) do
    @selenium_driver = TestingBot::SeleniumWebdriver.new
  end

  after(:each) do
    @selenium_driver.stop
  end

  context "Connect and run successfully to the TestingBot Grid with Selenium 2" do
    it "should be able to run an RC test successfully" do 
      @check_api = false
      @selenium_driver.navigate.to "http://testingbot.com"
      @selenium_driver.title.should match /^Selenium Testing/
    end
  end
end

describe "Selenium WebDriver test API" do

  before(:all) do
    @selenium_driver = TestingBot::SeleniumWebdriver.new
  end

  after(:each) do
    @selenium_driver.stop
  end

  context "Check that we report the test status back successfully" do
    it "should send a success status to TestingBot upon success of the test" do
      @check_api = true
      @selenium_driver.navigate.to "http://testingbot.com"
      @selenium_driver.title.should match /^Selenium Testing/
    end
  end
end