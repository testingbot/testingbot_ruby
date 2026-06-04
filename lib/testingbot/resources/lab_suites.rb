module TestingBot
  module Resources
    # Codeless Lab suite endpoints under /labsuites.
    module LabSuites
      def get_lab_suites(offset = 0, count = 10)
        get("/labsuites#{query(:offset => offset, :count => count)}")
      end

      def create_lab_suite(params = {})
        post("/labsuites", params)
      end

      def get_lab_suite(suite_id)
        get("/labsuites/#{escape(suite_id)}")
      end

      def delete_lab_suite(suite_id)
        delete("/labsuites/#{escape(suite_id)}")
      end

      def get_lab_suite_tests(suite_id)
        get("/labsuites/#{escape(suite_id)}/tests")
      end

      def add_lab_suite_tests(suite_id, params = {})
        post("/labsuites/#{escape(suite_id)}/tests", params)
      end

      def remove_lab_suite_test(suite_id, test_id)
        delete("/labsuites/#{escape(suite_id)}/tests/#{escape(test_id)}")
      end

      def get_lab_suite_browsers(suite_id)
        get("/labsuites/#{escape(suite_id)}/browsers")
      end

      def set_lab_suite_browsers(suite_id, params = {})
        post("/labsuites/#{escape(suite_id)}/browsers", params)
      end

      def trigger_lab_suite(suite_id, params = {})
        post("/labsuites/#{escape(suite_id)}/trigger", params)
      end
    end
  end
end
