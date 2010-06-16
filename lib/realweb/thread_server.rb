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
        boot_rack_server do |webrick_server|
          Thread.current[:kill_server] = lambda { webrick_server.shutdown }
        end
      end
    end
  end
end
