module TestingBot
  module Resources
    # Endpoints under /screenshots.
    module Screenshots
      def take_screenshots(configuration)
        post("/screenshots", configuration)
      end

      def get_screenshots_history(offset = 0, count = 10)
        get("/screenshots#{query(:offset => offset, :count => count)}")
      end

      # +params+ accepts the optional excludeIds query param.
      def get_screenshots(screenshots_id, params = {})
        get("/screenshots/#{escape(screenshots_id)}#{query(params)}")
      end
    end
  end
end
