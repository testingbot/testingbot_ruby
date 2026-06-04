RSpec.describe TestingBot::Api, "jobs endpoints" do
  include_context "recording api"

  it { api.get_job(99); expect_call(:get, "/jobs/99") }
end
