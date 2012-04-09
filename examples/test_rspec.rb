require 'rubygems'
require "selenium/client"
require 'rspec'
require 'testingbot'
require 'testingbot/tunnel'

TestingBot::config do |config|
  config[:desired_capabilities] = [{ :browserName => "firefox", :version => 9, :platform => "WINDOWS" }, { :browserName => "firefox", :version => 11, :platform => "WINDOWS" }]
end

# rspec 2
describe "People", :type => :selenium, :multibrowser => true do
    it "can find the right title" do    
      page.navigate.to "http://www.google.com"
      page.title.should eql("Google")   
    end
end