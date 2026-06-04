require 'digest'

module TestingBot
  module Resources
    # Test/build sharing helpers.
    module Sharing
      # Compute the hash used to share private tests/builds with other people.
      def get_authentication_hash(identifier)
        Digest::MD5.hexdigest("#{@key}:#{@secret}:#{identifier}")
      end
    end
  end
end
