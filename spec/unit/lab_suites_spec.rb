RSpec.describe TestingBot::Api, "codeless lab suite endpoints" do
  include_context "recording api"

  it { api.get_lab_suites; expect_call(:get, "/labsuites?offset=0&count=10") }
  it { api.create_lab_suite({ "name" => "s" }); expect_call(:post, "/labsuites", { "name" => "s" }) }
  it { api.get_lab_suite(2); expect_call(:get, "/labsuites/2") }
  it { api.delete_lab_suite(2); expect_call(:delete, "/labsuites/2") }
  it { api.get_lab_suite_tests(2); expect_call(:get, "/labsuites/2/tests") }
  it { api.add_lab_suite_tests(2, { "ids" => [1] }); expect_call(:post, "/labsuites/2/tests", { "ids" => [1] }) }
  it { api.remove_lab_suite_test(2, 5); expect_call(:delete, "/labsuites/2/tests/5") }
  it { api.get_lab_suite_browsers(2); expect_call(:get, "/labsuites/2/browsers") }
  it { api.set_lab_suite_browsers(2, { "b" => [] }); expect_call(:post, "/labsuites/2/browsers", { "b" => [] }) }
  it { api.trigger_lab_suite(2); expect_call(:post, "/labsuites/2/trigger") }
end
