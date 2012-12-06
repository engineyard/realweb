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
      self.port

      trap(:TERM) { kill_pid; exit!(0) }
      @pid = fork do
        process_as_child
      end
    end

    def process_as_child
      trap(:TERM) { exit!(0) }
      unless @verbose
        STDOUT.reopen '/dev/null', 'a'
        STDERR.reopen '/dev/null', 'a'
      end
      @server = rack_server
      @server.start
    end
  end
end
