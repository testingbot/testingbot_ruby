FakeResponse = Struct.new(:code, :body)

# Captures the keyword args passed to the HTTP client so we can assert how the
# Connection configures each request (timeouts, payload presence, auth).
class CapturingHttp
  attr_reader :calls

  def initialize(response)
    @response = response
    @calls = []
  end

  def execute(**args)
    @calls << args
    @response
  end

  def last
    @calls.last
  end
end

RSpec.describe TestingBot::Connection do
  def url(path)
    "https://api.testingbot.com/v1#{path}"
  end

  describe "request construction (via injected HTTP client)" do
    let(:http) { CapturingHttp.new(FakeResponse.new(200, "{}")) }
    let(:conn) { described_class.new(key: "k", secret: "s", http: http) }

    it "builds the versioned URL and sends HTTP Basic credentials" do
      conn.request(:get, "/user")
      expect(http.last[:method]).to eq(:get)
      expect(http.last[:url]).to eq(url("/user"))
      expect(http.last[:user]).to eq("k")
      expect(http.last[:password]).to eq("s")
    end

    it "applies default open/read timeouts" do
      conn.request(:get, "/user")
      expect(http.last[:open_timeout]).to eq(described_class::DEFAULT_OPEN_TIMEOUT)
      expect(http.last[:read_timeout]).to eq(described_class::DEFAULT_READ_TIMEOUT)
    end

    it "honors timeout overrides from options" do
      conn = described_class.new(key: "k", secret: "s",
                                 options: { open_timeout: 1, read_timeout: 2 }, http: http)
      conn.request(:get, "/user")
      expect(http.last[:open_timeout]).to eq(1)
      expect(http.last[:read_timeout]).to eq(2)
    end

    it "applies a per-call timeout (uploads)" do
      conn.request(:post, "/storage", { multipart: true }, timeout: 600)
      expect(http.last[:timeout]).to eq(600)
    end

    it "omits the payload on GET" do
      conn.request(:get, "/user")
      expect(http.last).not_to have_key(:payload)
    end

    it "omits the payload on DELETE with no params" do
      conn.request(:delete, "/tests/1")
      expect(http.last).not_to have_key(:payload)
    end

    it "sends the payload on POST with params" do
      conn.request(:post, "/storage", { url: "x" })
      expect(http.last[:payload]).to eq({ url: "x" })
    end
  end

  describe "response parsing and error mapping (via WebMock + real RestClient)" do
    let(:conn) { described_class.new(key: "k", secret: "s", options: { max_retries: 2 }) }

    before { allow(conn).to receive(:sleep) } # skip real backoff delays

    it "parses a JSON object body" do
      stub_request(:get, url("/user")).to_return(status: 200, body: '{"first_name":"Jo"}')
      expect(conn.request(:get, "/user")).to eq({ "first_name" => "Jo" })
    end

    it "returns {} for an empty body" do
      stub_request(:get, url("/user")).to_return(status: 200, body: "")
      expect(conn.request(:get, "/user")).to eq({})
    end

    it "raises ApiError when a 200 body carries an error field" do
      stub_request(:get, url("/user")).to_return(status: 200, body: '{"error":"nope"}')
      expect { conn.request(:get, "/user") }.to raise_error(TestingBot::ApiError, /nope/)
    end

    it "raises ParseError on a non-JSON body" do
      stub_request(:get, url("/user")).to_return(status: 200, body: "<html>maintenance</html>")
      expect { conn.request(:get, "/user") }
        .to raise_error(TestingBot::ParseError) { |e| expect(e.http_status).to eq(200) }
    end

    it "maps 401 to AuthenticationError carrying the status" do
      stub_request(:get, url("/user")).to_return(status: 401, body: "")
      expect { conn.request(:get, "/user") }
        .to raise_error(TestingBot::AuthenticationError) { |e| expect(e.http_status).to eq(401) }
    end

    it "maps 404 to NotFoundError" do
      stub_request(:get, url("/tests/1")).to_return(status: 404, body: "")
      expect { conn.request(:get, "/tests/1") }.to raise_error(TestingBot::NotFoundError)
    end

    it "sends HTTP Basic auth" do
      stubbed = stub_request(:get, url("/user")).with(basic_auth: ["k", "s"]).to_return(body: "{}")
      conn.request(:get, "/user")
      expect(stubbed).to have_been_requested
    end
  end

  describe "retries and backoff" do
    let(:conn) { described_class.new(key: "k", secret: "s", options: { max_retries: 2 }) }

    before { allow(conn).to receive(:sleep) }

    it "retries an idempotent GET on 503 and returns the eventual success" do
      stub_request(:get, url("/user"))
        .to_return({ status: 503, body: "" }, { status: 200, body: '{"ok":true}' })
      expect(conn.request(:get, "/user")).to eq({ "ok" => true })
    end

    it "raises ServerError after exhausting retries on a persistent 500" do
      stubbed = stub_request(:get, url("/user")).to_return(status: 500, body: "")
      expect { conn.request(:get, "/user") }.to raise_error(TestingBot::ServerError)
      expect(stubbed).to have_been_requested.times(3) # 1 initial + 2 retries
    end

    it "does NOT retry a non-idempotent POST on 500" do
      stubbed = stub_request(:post, url("/storage")).to_return(status: 500, body: "")
      expect { conn.request(:post, "/storage", { url: "x" }) }.to raise_error(TestingBot::ServerError)
      expect(stubbed).to have_been_requested.once
    end

    it "honors Retry-After on 429 and finally raises RateLimitError" do
      stubbed = stub_request(:get, url("/user"))
                .to_return(status: 429, headers: { "Retry-After" => "1" }, body: "")
      expect { conn.request(:get, "/user") }
        .to raise_error(TestingBot::RateLimitError) { |e| expect(e.retry_after).to eq(1) }
      expect(stubbed).to have_been_requested.times(3)
    end
  end

  describe "debug redaction" do
    it "redacts secret-bearing keys from debug output and never prints the value" do
      conn = described_class.new(key: "k", secret: "s", options: { debug: true })
      stub_request(:get, url("/user")).to_return(body: '{"secret":"topsecret","name":"x"}')

      original = $stderr
      $stderr = StringIO.new
      begin
        conn.request(:get, "/user")
        output = $stderr.string
      ensure
        $stderr = original
      end

      expect(output).to include("[REDACTED]")
      expect(output).not_to include("topsecret")
      expect(output).to include("name")
    end
  end
end
