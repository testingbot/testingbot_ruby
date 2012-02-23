require 'rubygems'
gem "rspec", "<2"
gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"
gem "testingbot"
require "testingbot"

describe "People" do
  attr_reader :selenium_driver
  alias :page :selenium_driver
  
  before(:all) do
        @selenium_driver = Selenium::Client::Driver.new \
            :host => "hub.testingbot.com",
            :port => 4444, 
            :browser => "firefox", 
            :url => "http://www.google.com", 
            :timeout_in_second => 60,
            :platform => "WINDOWS",
            :version => "10"
    end

    before(:each) do
      selenium_driver.start_new_browser_session
    end

    append_after(:each) do 
      @selenium_driver.close_current_browser_session
    end

    it "can find the right title" do    
      page.open "/"
      page.title.should eql("Google")   
    end
end