module TestingBot
  module Resources
    # Endpoints under /tunnel.
    module Tunnels
      def get_tunnels
        get("/tunnel/list")
      end

      # Fetch the active tunnel, or a specific tunnel by numeric ID.
      def get_tunnel(tunnel_identifier = nil)
        tunnel_identifier ? get("/tunnel/#{escape(tunnel_identifier)}") : get("/tunnel")
      end

      # Delete a tunnel by ID, or the active tunnel when called without an argument.
      def delete_tunnel(tunnel_identifier = nil)
        delete(tunnel_identifier ? "/tunnel/#{escape(tunnel_identifier)}" : "/tunnel")
      end
    end
  end
end
