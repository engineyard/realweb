module RealWeb
  class Server
    attr_reader :host, :rack_server

    DEFAULT_PORT_RANGE    = 8000..10000
    DEFAULT_HOST          = '127.0.0.1'
    DEFAULT_LOGGER        = Logger.new(StringIO.new)

    def self.with_rackup(*args)
      new(*args) do |server|
        server.start
        yield server if block_given?
        server.stop
      end
    end

    def initialize(config_ru, options = {})
      @config_ru  = config_ru
      @running    = false

      @port_range = options.delete(:port_range) || DEFAULT_PORT_RANGE
      @logger     = options.delete(:logger)     || DEFAULT_LOGGER
      @host       = options.delete(:host)       || DEFAULT_HOST
      @verbose    = options.delete(:verbose)    || false

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
        :Logger     => @logger,
        :AccessLog  => @access_log
      ))
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
