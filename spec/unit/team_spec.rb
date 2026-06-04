RSpec.describe TestingBot::Api, "team-management endpoints" do
  include_context "recording api"

  it { api.get_team; expect_call(:get, "/team-management") }
  it { api.get_users_in_team(5, 20); expect_call(:get, "/team-management/users?offset=5&count=20") }
  it { api.get_user_in_team(7); expect_call(:get, "/team-management/users/7") }
  it { api.get_user_client_key(7); expect_call(:get, "/team-management/users/7/client-key") }
  it { api.create_user_in_team({ "email" => "a@b.c" }); expect_call(:post, "/team-management/users", { "email" => "a@b.c" }) }
  it { api.update_user_in_team(7, { "first_name" => "x" }); expect_call(:put, "/team-management/users/7", { "first_name" => "x" }) }
  it { api.reset_credentials(7); expect_call(:post, "/team-management/users/7/reset-keys") }
end
