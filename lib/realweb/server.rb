require 'rack'
require 'timeout'
require 'logger'
require 'uri'
require 'open-uri'
require 'stringio'

module RealWeb
  class Server
    attr_reader :host, :rack_server

    DEFAULT_PORT_RANGE    = 8000..10000
    DEFAULT_HOST          = '127.0.0.1'
    DEFAULT_TIMEOUT       = 2 # seconds

    # return true if available, false if still waiting
    def self.server_ready?(server)
      http = Net::HTTP.start(server.host, server.port, {open_timeout: DEFAULT_TIMEOUT, read_timeout: DEFAULT_TIMEOUT})
      response = http.head("/")
      true
    rescue Timeout::Error, SocketError, Errno::ECONNREFUSED
      false
    end

    def self.default_logger(verbose = false)
      logger = Logger.new($stderr)
      logger.level = Logger::FATAL unless verbose
      logger
    end

    def self.with_rackup(*args)
      new(*args) do |server|
        server.start
        yield server if block_given?
        server.stop
      end
    end

    # Create a RealWeb::Server object, either a RealWeb::ForkingServer or
    # a RealWeb::ThreadServer.
    #
    # :port_range - Range specifying acceptable tcp ports to boot on.
    # :logger     - An instance of Logger.
    # :host       - Alternative host. Default is 127.0.0.1.
    # :verbose    - Print server logs and errors
    # :timeout    - Timout in seconds to wait for the server to boot.
    # :ready      - A Proc that returns true when the server is ready, or false
    #     if it is not ready yet. This proc will be called every 100ms with the
    #     server as an argument. If blank, an open-uri based check will be used.
    # :pre_spawn_callback - a lambda to be called with the server object before
    #     spawning the server.
    #
    # Any remaining options will be passed to Rack::Server on boot.
    def initialize(config_ru, options = {})
      @config_ru  = config_ru
      @running    = false

      @port_range = options.delete(:port_range) || DEFAULT_PORT_RANGE
      @host       = options.delete(:host)       || DEFAULT_HOST
      @verbose    = options.delete(:verbose)    || false
      @timeout    = options.delete(:timeout)    || DEFAULT_TIMEOUT
      @ready      = options.delete(:ready)      || self.class.method(:server_ready?)
      @logger     = options.delete(:logger)     || self.class.default_logger(@verbose)

      @pre_spawn_callback = options.delete(:pre_spawn_callback)
      @rack_options = options

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
      run_pre_spawn
      spawn_server
      wait_for_server
      @running = true
    rescue RealWeb::ServerUnreachable
      stop
      raise
    end

    def stop
      @running = false
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

    def rack_server
      Rack::Server.new(@rack_options.merge(
        :Port       => port,
        :Host       => host,
        :config     => @config_ru,
        :Logger     => @logger
      ))
    end

    def wait_for_server
      Timeout.timeout(@timeout) do
        begin
          sleep 0.1
        end until @ready.call(self)
      end
    rescue Timeout::Error
      verbose_msg = @verbose ? "" : "\nBoot RealWeb with {verbose: true} to print errrors."
      raise RealWeb::ServerUnreachable, <<-ERROR
Unable to reach RealWeb server after #{@timeout}s: #{@config_ru}.#{verbose_msg}
      ERROR
    end

  end
end
