require 'realweb/server'

module RealWeb
  class ForkingServer < Server

    def stop
      kill_pid
      super
    end

    protected

    def kill_pid
      return unless @pid
      Process.kill 'INT', @pid
      Process.kill 'TERM', @pid
      Process.wait @pid
    rescue
      # noop
    ensure
      @pid = nil
    end

    def spawn_server
      @pid ||= Process.fork do
        boot_rack_server do |mongrel_server|
          trap(:TERM) { mongrel_server.stop; exit!(0) }
        end
      end
    end
  end
end
