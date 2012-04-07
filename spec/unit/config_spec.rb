require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TestingBot::Config do
  describe '#[]' do
    it "should return nil for options that don't exist" do
      c = TestingBot::Config.new
      c[:doesnotexist].should be_nil
    end

    it "should return a config value when being set from the constructor" do
      c = TestingBot::Config.new({ :client_secret => "secret!!" })
      c[:client_secret].should == "secret!!"
    end
  end

  describe '#[]=' do
  	it "should successfully set a config value" do
      c = TestingBot::Config.new
      value = rand * 1000
      c[:client_key] = value
      c[:client_key].should == value
    end
  end

  describe "read config file" do
  	it "should read values from the .testingbot config file" do
  		if File.exists?(File.expand_path("~/.testingbot"))
  			c = TestingBot::Config.new
  			client_key, client_secret = File.open(File.expand_path("~/.testingbot")) { |f| f.readline }.chomp.split(":")
  			c[:client_key].should == client_key
  		end
  	end

  	it "should use the options I pass in the constructor, even if I have a config file" do
		if File.exists?(File.expand_path("~/.testingbot"))
  			c = TestingBot::Config.new({ :client_key => "pickme" })
  			client_key, client_secret = File.open(File.expand_path("~/.testingbot")) { |f| f.readline }.chomp.split(":")
  			c[:client_key].should == "pickme"
  		end
  	end
  end
end