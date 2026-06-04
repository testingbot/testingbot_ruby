RSpec.describe TestingBot::Api, "codeless lab test endpoints" do
  include_context "recording api"

  it { api.get_lab_tests; expect_call(:get, "/lab?offset=0&count=10") }
  it { api.create_lab_test({ "test[name]" => "x" }); expect_call(:post, "/lab", { "test[name]" => "x" }) }
  it { api.get_lab_test(1); expect_call(:get, "/lab/1") }
  it { api.update_lab_test(1, { "a" => 1 }); expect_call(:put, "/lab/1", { "a" => 1 }) }
  it { api.delete_lab_test(1); expect_call(:delete, "/lab/1") }
  it { api.get_lab_test_steps(1); expect_call(:get, "/lab/1/steps") }
  it { api.set_lab_test_steps(1, { "s" => [] }); expect_call(:post, "/lab/1/steps", { "s" => [] }) }
  it { api.get_lab_test_browsers(1); expect_call(:get, "/lab/1/browsers") }
  it { api.set_lab_test_browsers(1, { "b" => [] }); expect_call(:post, "/lab/1/browsers", { "b" => [] }) }
  it { api.add_lab_test_alert(1, { "x" => 1 }); expect_call(:post, "/lab/1/alert", { "x" => 1 }) }
  it { api.update_lab_test_alert(1, { "x" => 1 }); expect_call(:put, "/lab/1/alert", { "x" => 1 }) }
  it { api.create_lab_test_report(1, { "x" => 1 }); expect_call(:post, "/lab/1/report", { "x" => 1 }) }
  it { api.update_lab_test_report(1, { "x" => 1 }); expect_call(:put, "/lab/1/report", { "x" => 1 }) }
  it { api.schedule_lab_test(1, { "cron" => "* * * * *" }); expect_call(:post, "/lab/1/schedule", { "cron" => "* * * * *" }) }
  it { api.trigger_lab_test(1); expect_call(:post, "/lab/1/trigger") }
  it { api.stop_lab_test(1); expect_call(:put, "/lab/1/stop") }
  it { api.trigger_all_lab_tests; expect_call(:post, "/lab/trigger_all") }
end
