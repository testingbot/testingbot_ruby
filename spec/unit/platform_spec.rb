RSpec.describe TestingBot::Api, "browser / device / configuration endpoints" do
  include_context "recording api"

  it { api.get_browsers; expect_call(:get, "/browsers") }
  it { api.get_devices; expect_call(:get, "/devices") }
  it { api.get_devices("android", true); expect_call(:get, "/devices?platform=android&web=true") }
  it { api.get_available_devices; expect_call(:get, "/devices/available") }
  it { api.get_device(42); expect_call(:get, "/devices/42") }
  it { api.get_ip_ranges; expect_call(:get, "/configuration/ip-ranges") }
end
