module TestingBot
  module Resources
    # Endpoints under /team-management.
    module Team
      def get_team
        get("/team-management")
      end

      def get_users_in_team(offset = 0, count = 10)
        get("/team-management/users#{query(:offset => offset, :count => count)}")
      end

      def get_user_in_team(user_id)
        get("/team-management/users/#{escape(user_id)}")
      end

      # Fetch a team member's API client key (requires ADMIN rights).
      def get_user_client_key(user_id)
        get("/team-management/users/#{escape(user_id)}/client-key")
      end

      def create_user_in_team(user = {})
        post("/team-management/users", user)
      end

      def update_user_in_team(user_id, user = {})
        put("/team-management/users/#{escape(user_id)}", user)
      end

      def reset_credentials(user_id)
        post("/team-management/users/#{escape(user_id)}/reset-keys")
      end
    end
  end
end
