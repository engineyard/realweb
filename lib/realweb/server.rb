require 'rack'
require 'stringio'
require 'logger'
require 'open-uri'

module RealWeb
  class Server
    DEFAULT_PORT_RANGE = 8000..10000

    def self.with_rackup(*args)
      new(*args) do |server|
        server.start
        yield server if block_given?
        server.stop
      end
    end

    def initialize(config_ru, pre_spawn_callback = nil, port_range = DEFAULT_PORT_RANGE)
      @config_ru, @pre_spawn_callback, @port_range = config_ru, pre_spawn_callback, port_range
      @running = false
      yield self if block_given?
    end

    def port
      @port ||= find_port
    end

    def running?
      @running
    end

    def start
      return if running?
      port
      run_pre_spawn
      spawn_server
      at_exit { stop }
      wait_for_server
      @running = true
    end

    def stop
      @running = false
    end

    def host
      "127.0.0.1"
    end

    def base_uri
      URI.parse("http://#{host}:#{port}/")
    end

    protected

    def find_port
      begin
        port = random_port
      end while system("lsof -i tcp:#{port} > /dev/null")
      port
    end

    def random_port
      @port_range.to_a[rand(@port_range.to_a.size)]
    end

    def run_pre_spawn
      @pre_spawn_callback.call(self) if @pre_spawn_callback
    end

    def spawn_server
      raise "Not implemented"
    end

    # hack around Rack::Server not yielding the real server
    def boot_rack_server(&block)
      begin
        rack_server = Rack::Server.new(
          :Port      => port,
          :config    => @config_ru,
          :server    => 'mongrel'
        )
        mongrel_handler = rack_server.server
        wrapped_app = rack_server.send(:wrapped_app)
        mongrel_handler.run(wrapped_app, rack_server.options, &block)
      rescue
        $stderr.puts "Failed to start server"
        $stderr.puts $!.inspect
        $stderr.puts $!.backtrace
        abort
      end
    end

    def wait_for_server
      20.times do
        begin
          open(base_uri)
          return
        rescue OpenURI::HTTPError
          return
        rescue Errno::ECONNREFUSED => e
          sleep 2
        end
      end
      abort "Unable to reach RealWeb server: Problem booting #{@config_ru}"
    end
  end
end
