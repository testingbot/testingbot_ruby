RSpec.describe TestingBot::Api, "builds endpoints" do
  include_context "recording api"

  it { api.get_builds(1, 2); expect_call(:get, "/builds?offset=1&count=2") }

  it "passes the build identifier through unescaped (wildcard route) with optional query" do
    api.get_build("my/build", skip_fields: "logs")
    expect_call(:get, "/builds/my/build?skip_fields=logs")
  end

  it { api.delete_build("b1"); expect_call(:delete, "/builds/b1") }
end
