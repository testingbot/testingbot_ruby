module TestingBot
  module Tunnel
    def self.start_tunnel(host, port, localport = 80)
      @@pid = fork do
        exec "ssh -gNR #{port}:localhost:#{localport} #{host}"
      end
    end

    def self.stop_tunnel
      if @@pid
        Process.kill "TERM", @@pid
        Process.wait @@pid
      end
    end
  end
end