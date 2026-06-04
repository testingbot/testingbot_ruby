RSpec.describe TestingBot::Api, "tests endpoints" do
  include_context "recording api"

  it { api.get_tests; expect_call(:get, "/tests?offset=0&count=10") }
  it { api.get_tests(2, 5, since: 123, build: "b1"); expect_call(:get, "/tests?offset=2&count=5&since=123&build=b1") }
  it { api.get_test("sess-123"); expect_call(:get, "/tests/sess-123") }

  it "URL-encodes reserved characters in the id" do
    api.get_test("a/b?c")
    expect(conn.last[:path]).to eq("/tests/a%2Fb%3Fc")
  end

  it "wraps update_test and coerces success" do
    conn.response = { "success" => true }
    expect(api.update_test(9, "name" => "y")).to eq(true)
    expect_call(:put, "/tests/9", { "test[name]" => "y" })
  end

  it "coerces delete_test / stop_test to booleans" do
    conn.response = { "success" => true }
    expect(api.delete_test(9)).to eq(true)
    expect_call(:delete, "/tests/9")
    expect(api.stop_test(9)).to eq(true)
    expect_call(:put, "/tests/9/stop")
  end
end
