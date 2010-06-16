require 'realweb/thread_server'
require 'realweb/forking_server'

module RealWeb
  class << self
    def start_server_in_thread(*args)
      ThreadServer.new(*args) { |server| server.start }
    end

    def start_server_in_fork(*args)
      ForkingServer.new(*args) { |server| server.start }
    end
    alias start_server start_server_in_fork

    def with_server_in_thread(*args, &block)
      ThreadServer.with_rackup(*args, &block)
    end

    def with_server_in_fork(*args, &block)
      ForkingServer.with_rackup(*args, &block)
    end
    alias with_server with_server_in_fork
  end
end
