require "tmpdir"

RSpec.describe TestingBot::Api, "storage endpoints" do
  include_context "recording api"

  it { api.upload_remote_file("https://x/app.apk"); expect_call(:post, "/storage", { url: "https://x/app.apk" }) }
  it { api.get_uploaded_files(0, 30); expect_call(:get, "/storage?offset=0&count=30") }

  it "strips the tb:// scheme on reads" do
    api.get_uploaded_file("tb://abc123")
    expect_call(:get, "/storage/abc123")
  end

  it "coerces delete_uploaded_file to a boolean and strips tb://" do
    conn.response = { "success" => true }
    expect(api.delete_uploaded_file("tb://abc123")).to eq(true)
    expect_call(:delete, "/storage/abc123")
  end

  it { api.update_remote_file("tb://abc", "https://x/new.apk"); expect_call(:post, "/storage/abc", { url: "https://x/new.apk" }) }

  it "uploads a local file as multipart with a 600s timeout, through the connection" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "app.apk")
      File.write(path, "binary")
      api.upload_local_file(path)
      call = conn.last
      expect(call[:verb]).to eq(:post)
      expect(call[:path]).to eq("/storage")
      expect(call[:params][:multipart]).to eq(true)
      expect(call[:params][:file]).to be_a(File)
      expect(call[:opts]).to eq(timeout: 600)
    end
  end
end
