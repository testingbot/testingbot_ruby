# Records every request the Api makes so specs can assert the exact verb, path
# and payload each endpoint produces — without any network access. Also exercises
# the dependency-injection seam (options[:connection]).
class RecordingConnection
  attr_reader :calls
  attr_accessor :response

  def initialize(response = {})
    @calls = []
    @response = response
  end

  def request(verb, path, params = {}, opts = {})
    @calls << { verb: verb, path: path, params: params, opts: opts }
    @response
  end

  def last
    @calls.last
  end
end

# Shared setup for the per-category Api contract specs.
RSpec.shared_context "recording api" do
  let(:conn) { RecordingConnection.new }
  let(:api)  { TestingBot::Api.new("mykey", "mysecret", connection: conn) }

  def expect_call(verb, path, params = {})
    expect(conn.last[:verb]).to eq(verb)
    expect(conn.last[:path]).to eq(path)
    expect(conn.last[:params]).to eq(params)
  end
end
