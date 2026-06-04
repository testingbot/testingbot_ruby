module TestingBot
  module Resources
    # TestingBot Storage endpoints under /storage (mobile app testing).
    #
    # App URLs target a wildcard route, so they are only stripped of their
    # tb:// scheme (slashes are preserved, not escaped).
    module Storage
      def upload_local_file(file_path)
        File.open(file_path, 'rb') do |io|
          @connection.request(:post, "/storage", { :multipart => true, :file => io }, :timeout => 600)
        end
      end

      def upload_remote_file(url)
        post("/storage", { :url => url })
      end

      # Replace the binary stored under an existing app key with a local file.
      def update_local_file(app_url, file_path)
        File.open(file_path, 'rb') do |io|
          @connection.request(:post, "/storage/#{strip_scheme(app_url)}",
                              { :multipart => true, :file => io }, :timeout => 600)
        end
      end

      # Replace the binary stored under an existing app key with a remote URL.
      def update_remote_file(app_url, url)
        post("/storage/#{strip_scheme(app_url)}", { :url => url })
      end

      def get_uploaded_files(offset = 0, count = 10)
        get("/storage#{query(:offset => offset, :count => count)}")
      end

      def get_uploaded_file(app_url)
        get("/storage/#{strip_scheme(app_url)}")
      end

      def delete_uploaded_file(app_url)
        success?(delete("/storage/#{strip_scheme(app_url)}"))
      end
    end
  end
end
