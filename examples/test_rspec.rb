require 'rubygems'
require "selenium/client"
require 'rspec'
require 'testingbot'
#require 'testingbot/tunnel'

# rspec 2
describe "People", :type => :selenium do
  attr_reader :selenium_driver
    before(:all) do
        #TestingBot::Tunnel.start_tunnel("selenium@tunnel.testingbot.com", 2052)

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
      @selenium_driver.start_new_browser_session
    end
  
    after(:each) do
      @selenium_driver.close_current_browser_session
    end
      
    it "can find the right title" do    
      @selenium_driver.open "/"
      @selenium_driver.title.should eql("Google")   
    end

    # after(:all) do
    #   TestingBot::Tunnel.stop_tunnel
    # end
end