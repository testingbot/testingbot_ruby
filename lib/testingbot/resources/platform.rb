module TestingBot
  module Resources
    # Browser, device and configuration endpoints.
    module Platform
      def get_browsers
        get("/browsers")
      end

      # Optionally filter server-side by platform and/or web capability.
      def get_devices(platform = nil, web = nil)
        get("/devices#{query(:platform => platform, :web => web)}")
      end

      def get_available_devices
        get("/devices/available")
      end

      # Fetch a single physical device by its numeric ID.
      def get_device(device_id)
        get("/devices/#{escape(device_id)}")
      end

      # List the IP ranges TestingBot tests originate from (firewall allow-listing).
      def get_ip_ranges
        get("/configuration/ip-ranges")
      end
    end
  end
end
