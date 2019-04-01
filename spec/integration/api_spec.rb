require "uri"
require "net/http"
require 'rspec'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Testingbot Api" do
  context "the API should return valid user information" do
    it "should return info for the current user" do 
      @api = TestingBot::Api.new
      @api.get_user_info.should_not be_empty
      @api.get_user_info["first_name"].should_not be_empty
    end

    it "should raise an error when wrong credentials are provided" do
      @api = TestingBot::Api.new("bogus", "false")
      lambda { @api.get_user_info }.should raise_error(RestClient::Unauthorized)
    end
  end

  context "updating my user info via the API should work" do
    it "should allow me to update my own user info" do
      @api = TestingBot::Api.new
      new_name = rand(36**9).to_s(36)
      @api.update_user_info({ "first_name" => new_name }).should == true
      @api.get_user_info["first_name"].should == new_name
    end
  end

  context "retrieve my own tests" do
    it "should retrieve a list of my own tests" do
      @api = TestingBot::Api.new
      @api.get_tests.include?("data").should == true
    end

    it "should provide info for a specific test" do
      @api = TestingBot::Api.new
      data = @api.get_tests["data"]
      if data.length > 0
        test_id = data.first["id"]
        
        single_test = @api.get_test(test_id)
        single_test["id"].should == test_id
      end
    end

    it "should fail when trying to access a test that is not mine" do
      @api = TestingBot::Api.new
      lambda { @api.get_test(123423423423423) }.should raise_error(RestClient::NotFound)
    end
  end

  context "update a test" do
    it "should update a test of mine" do
      @api = TestingBot::Api.new
      data = @api.get_tests["data"]
      if data.length > 0
        test_id = data.first["id"]
        new_name = rand(36**9).to_s(36)
        @api.update_test(test_id, { :name => new_name }).should == true
        single_test = @api.get_test(test_id)
        single_test["name"].should == new_name
      end
    end

    it "should not update a test that is not mine" do
      @api = TestingBot::Api.new
      lambda { @api.update_test(123423423423423, { :name => "testingbot" }) }.should raise_error(RestClient::NotFound)
    end
  end

  context "fetch browsers" do
    it "should fetch a list of browsers" do
      @api = TestingBot::Api.new
      @api.get_browsers.should_not be_empty
    end
  end

  context "delete a test" do
    it "should delete a test of mine" do
      @api = TestingBot::Api.new
      data = @api.get_tests["data"]
      if data.length > 0
        test_id = data.first["id"]
        @api.delete_test(test_id).should == true
        lambda { @api.get_test(test_id) }.should raise_error(RestClient::NotFound)
      end
    end

    it "should not delete a test that is not mine" do
      @api = TestingBot::Api.new
      lambda { @api.delete_test(123423423423423) }.should raise_error(RestClient::NotFound)
    end
  end

  context "TestingBot Storage" do
    it "should upload a local file" do
      @api = TestingBot::Api.new
      response = @api.upload_local_file(File.join(File.dirname(__FILE__), "../resources/test.apk"))
      response["app_url"].should include("tb://")
    end

    it "should upload a remote file" do
      @api = TestingBot::Api.new
      response = @api.upload_remote_file("https://testingbot.com/appium/sample.apk")
      response["app_url"].should include("tb://")
    end
  end
end