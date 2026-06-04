require "tmpdir"

RSpec.describe TestingBot::Api, "credential resolution" do
  include_context "recording api"

  around do |example|
    saved = %w[TB_KEY TB_SECRET TESTINGBOT_KEY TESTINGBOT_SECRET HOME].map { |k| [k, ENV[k]] }
    example.run
    saved.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
  end

  it "uses explicit arguments first" do
    api = described_class.new("k", "s", connection: conn)
    expect(api.key).to eq("k")
    expect(api.secret).to eq("s")
  end

  it "falls back to TESTINGBOT_* then TB_* env vars when no config file exists" do
    %w[TB_KEY TB_SECRET TESTINGBOT_KEY TESTINGBOT_SECRET].each { |k| ENV.delete(k) }
    Dir.mktmpdir do |home|
      ENV["HOME"] = home # empty dir: no ~/.testingbot to take precedence
      ENV["TB_KEY"] = "envkey"
      ENV["TB_SECRET"] = "envsecret"
      api = described_class.new(nil, nil, connection: conn)
      expect(api.key).to eq("envkey")
      expect(api.secret).to eq("envsecret")
    end
  end

  it "reads ~/.testingbot and preserves a ':' in the secret (split on first colon only)" do
    %w[TB_KEY TB_SECRET TESTINGBOT_KEY TESTINGBOT_SECRET].each { |k| ENV.delete(k) }
    Dir.mktmpdir do |home|
      ENV["HOME"] = home
      path = File.join(home, ".testingbot")
      File.write(path, "filekey:fil:esecret")
      File.chmod(0o600, path)
      api = described_class.new(nil, nil, connection: conn)
      expect(api.key).to eq("filekey")
      expect(api.secret).to eq("fil:esecret")
    end
  end

  it "raises when key or secret cannot be resolved" do
    %w[TB_KEY TB_SECRET TESTINGBOT_KEY TESTINGBOT_SECRET].each { |k| ENV.delete(k) }
    Dir.mktmpdir do |home|
      ENV["HOME"] = home
      expect { described_class.new(nil, nil, connection: conn) }
        .to raise_error(/Please supply a TestingBot Key/)
    end
  end
end
