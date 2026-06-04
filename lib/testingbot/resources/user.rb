module TestingBot
  module Resources
    # Endpoints under /user.
    module User
      def get_user_info
        get("/user")
      end

      def update_user_info(params = {})
        success?(put("/user", wrap_params("user", params)))
      end

      # Retrieve the account's API key/secret pair.
      def get_user_keys
        get("/user/keys")
      end
    end
  end
end
