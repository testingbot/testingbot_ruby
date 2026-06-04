RSpec.describe TestingBot::Api, "screenshots endpoints" do
  include_context "recording api"

  it { api.take_screenshots({ "url" => "https://x" }); expect_call(:post, "/screenshots", { "url" => "https://x" }) }
  it { api.get_screenshots_history(3, 4); expect_call(:get, "/screenshots?offset=3&count=4") }
  it { api.get_screenshots(11); expect_call(:get, "/screenshots/11") }
  it { api.get_screenshots(11, excludeIds: "1,2"); expect_call(:get, "/screenshots/11?excludeIds=1%2C2") }
end
