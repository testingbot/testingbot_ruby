RSpec.describe TestingBot::Api, "user endpoints" do
  include_context "recording api"

  it { api.get_user_info; expect_call(:get, "/user") }
  it { api.get_user_keys; expect_call(:get, "/user/keys") }

  it "wraps update_user_info params and coerces success to a boolean" do
    conn.response = { "success" => true }
    expect(api.update_user_info("first_name" => "Jo")).to eq(true)
    expect_call(:put, "/user", { "user[first_name]" => "Jo" })
  end

  it "returns false from update_user_info when no success key is present" do
    conn.response = { "user" => {} }
    expect(api.update_user_info("first_name" => "Jo")).to eq(false)
  end
end
