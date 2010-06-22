require 'realweb/server'

module RealWeb
  class ThreadServer < Server

    def stop
      @thread[:kill_server].call
      @thread.kill
      super
    end

    protected

    def spawn_server
      @thread ||= Thread.new do
        boot_rack_server do |mongrel_server|
          Thread.current[:kill_server] = lambda { mongrel_server.stop }
        end
      end
    end
  end
end
