module TestingBot
  module Resources
    # Endpoints under /tests.
    module Tests
      # +filters+ accepts the backend's optional query params: since, browser_id,
      # group, build, skip_fields.
      def get_tests(offset = 0, count = 10, filters = {})
        get("/tests#{query({ :offset => offset, :count => count }.merge(filters))}")
      end

      def get_test(test_id)
        get("/tests/#{escape(test_id)}")
      end

      def update_test(test_id, params = {})
        success?(put("/tests/#{escape(test_id)}", wrap_params("test", params)))
      end

      def delete_test(test_id)
        success?(delete("/tests/#{escape(test_id)}"))
      end

      def stop_test(test_id)
        success?(put("/tests/#{escape(test_id)}/stop"))
      end
    end
  end
end
