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

      unless @pid = fork
        process_as_child
      end
    end

    def process_as_child
      trap(:TERM) { exit!(0) }
      @server = rack_server
      @server.start
    end
  end
end
