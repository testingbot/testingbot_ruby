RSpec.describe TestingBot::Api, "tunnel endpoints" do
  include_context "recording api"

  it { api.get_tunnels; expect_call(:get, "/tunnel/list") }
  it { api.get_tunnel; expect_call(:get, "/tunnel") }
  it { api.get_tunnel(8); expect_call(:get, "/tunnel/8") }
  it { api.delete_tunnel(8); expect_call(:delete, "/tunnel/8") }
  it { api.delete_tunnel; expect_call(:delete, "/tunnel") }
end
