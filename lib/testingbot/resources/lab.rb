module TestingBot
  module Resources
    # Codeless Lab test endpoints under /lab.
    module Lab
      def get_lab_tests(offset = 0, count = 10)
        get("/lab#{query(:offset => offset, :count => count)}")
      end

      def create_lab_test(params = {})
        post("/lab", params)
      end

      def get_lab_test(lab_test_id)
        get("/lab/#{escape(lab_test_id)}")
      end

      def update_lab_test(lab_test_id, params = {})
        put("/lab/#{escape(lab_test_id)}", params)
      end

      def delete_lab_test(lab_test_id)
        delete("/lab/#{escape(lab_test_id)}")
      end

      def get_lab_test_steps(lab_test_id)
        get("/lab/#{escape(lab_test_id)}/steps")
      end

      def set_lab_test_steps(lab_test_id, params = {})
        post("/lab/#{escape(lab_test_id)}/steps", params)
      end

      def get_lab_test_browsers(lab_test_id)
        get("/lab/#{escape(lab_test_id)}/browsers")
      end

      def set_lab_test_browsers(lab_test_id, params = {})
        post("/lab/#{escape(lab_test_id)}/browsers", params)
      end

      def add_lab_test_alert(lab_test_id, params = {})
        post("/lab/#{escape(lab_test_id)}/alert", params)
      end

      def update_lab_test_alert(lab_test_id, params = {})
        put("/lab/#{escape(lab_test_id)}/alert", params)
      end

      def create_lab_test_report(lab_test_id, params = {})
        post("/lab/#{escape(lab_test_id)}/report", params)
      end

      def update_lab_test_report(lab_test_id, params = {})
        put("/lab/#{escape(lab_test_id)}/report", params)
      end

      def schedule_lab_test(lab_test_id, params = {})
        post("/lab/#{escape(lab_test_id)}/schedule", params)
      end

      def trigger_lab_test(lab_test_id, params = {})
        post("/lab/#{escape(lab_test_id)}/trigger", params)
      end

      def stop_lab_test(lab_test_id)
        put("/lab/#{escape(lab_test_id)}/stop")
      end

      def trigger_all_lab_tests(params = {})
        post("/lab/trigger_all", params)
      end
    end
  end
end
