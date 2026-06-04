# Live integration suite. These examples hit the real TestingBot API and are
# tagged :integration so they only run when explicitly requested
# (`bundle exec rake integration`) with TB_KEY / TB_SECRET present.
#
# They are written to be non-destructive: the one write (renaming the account)
# restores the original value in an ensure block.
RSpec.describe "TestingBot API (live)", :integration do
  let(:api) { TestingBot::Api.new }

  context "user information" do
    it "returns info for the current user" do
      info = api.get_user_info
      expect(info).not_to be_empty
      expect(info["first_name"]).not_to be_nil
    end

    it "raises AuthenticationError for invalid credentials" do
      bogus = TestingBot::Api.new("bogus", "invalid")
      expect { bogus.get_user_info }.to raise_error(TestingBot::AuthenticationError)
    end
  end

  context "updating user info" do
    it "round-trips first_name and restores the original value" do
      original = api.get_user_info["first_name"]
      new_name = "rspec-#{rand(36**9).to_s(36)}"
      begin
        expect(api.update_user_info("first_name" => new_name)).to eq(true)
        expect(api.get_user_info["first_name"]).to eq(new_name)
      ensure
        api.update_user_info("first_name" => original)
      end
    end
  end

  context "tests" do
    it "lists tests with pagination metadata" do
      expect(api.get_tests).to include("data")
    end

    it "raises NotFoundError for a test that does not exist" do
      expect { api.get_test(123423423423423) }.to raise_error(TestingBot::NotFoundError)
    end
  end

  context "browsers and devices" do
    it "lists available browsers" do
      expect(api.get_browsers).not_to be_empty
    end

    it "lists available devices" do
      expect(api.get_devices).not_to be_empty
    end
  end

  context "sharing" do
    it "computes an authentication hash without raising" do
      expect(api.get_authentication_hash("session-123")).to match(/\A[0-9a-f]{32}\z/)
    end
  end
end
