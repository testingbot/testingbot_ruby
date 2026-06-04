module TestingBot
  module Resources
    # Endpoints under /builds.
    module Builds
      def get_builds(offset = 0, count = 10)
        get("/builds#{query(:offset => offset, :count => count)}")
      end

      # +params+ accepts optional offset/count/skip_fields query params.
      # The build identifier maps to a wildcard route, so it is passed through
      # unescaped to preserve any slashes it may contain.
      def get_build(build_identifier, params = {})
        get("/builds/#{build_identifier}#{query(params)}")
      end

      def delete_build(build_identifier)
        delete("/builds/#{build_identifier}")
      end
    end
  end
end
