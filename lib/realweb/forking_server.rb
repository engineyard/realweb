require 'realweb/server'

module RealWeb
  class ForkingServer < Server

    KILL_TIMEOUT = 2.0 # second

    def stop
      kill_pid
      super
    end

    protected

    # Kill, with increasing severity within KILL_TIMEOUT
    # Tries each signal, giving equal time for each signal to work.
    def kill_pid(signals = [:INT, :TERM, :KILL], timeout = KILL_TIMEOUT / signals.size.to_f)
      return unless @pid
      signal, *next_signals = *signals
      Process.kill signal, @pid
      Timeout.timeout(timeout) { Process.wait @pid }
      @pid = nil
    rescue Timeout::Error
      if next_signals.empty?
        raise Timeout::Error, "Unable to kill server process within #{KILL_TIMEOUT} seconds (amazingly)"
      end

      kill_pid(next_signals, timeout)
    rescue Errno::ECHILD, Errno::ESRCH
      # process doesn't exist
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
