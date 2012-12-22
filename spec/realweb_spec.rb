require 'spec_helper'

describe RealWeb do
  shared_examples_for "working server" do
    describe ".start_server" do
      before { @server = start_server }
      after { @server.stop }

      it "starts an accessible server" do
        open(@server.base_uri).read.should == "Hello World"
      end
    end

    describe ".with_server" do
      it "starts an accessible server" do
        with_server do |server|
          open(server.base_uri).read.should == "Hello World"
        end
      end
    end

    describe "works with" do
      it 'webrick' do
        with_server(:server => 'webrick') do |server|
          open(server.base_uri).read.should == "Hello World"
        end
      end

      it 'puma' do
        with_server(:server => 'puma') do |server|
          open(server.base_uri).read.should == "Hello World"
        end
      end
    end
  end

  describe "InThreadServer" do
    def start_server(options={})
      RealWeb.start_server_in_thread(config_ru, options.merge(:verbose => debug?))
    end

    def with_server(options={}, &block)
      RealWeb.with_server_in_thread(config_ru, options.merge(:verbose => debug?), &block)
    end

    it_should_behave_like "working server"

    describe ".start_server" do
      before { @server = start_server }
      after { @server.stop }
    end

  end

  describe "ForkingServer" do
    def start_server(options={})
      RealWeb.start_server_in_fork(config_ru, options.merge(:verbose => debug?))
    end

    def with_server(options={}, &block)
      RealWeb.with_server_in_fork(config_ru, options.merge(:verbose => debug?), &block)
    end

    it_should_behave_like "working server"

    describe ".with_server" do
      it "cleans up the server block exit" do
        base_uri = nil
        with_server { |server| base_uri = server.base_uri }
        lambda { open(base_uri) }.should raise_error(Errno::ECONNREFUSED)
      end
    end

    describe ".start_server" do
      before { @server = start_server }
      after { @server.stop }

      it "becomes inaccessible when stop is called" do
        @server.stop
        lambda { open(@server.base_uri) }.should raise_error(Errno::ECONNREFUSED)
      end
    end
  end

  describe "Server" do
    it "#port can be accessed & determined before boot" do
      server = RealWeb::ForkingServer.new(config_ru)
      port = server.port
      server.start
      server.port.should == port
      server.stop
      port.to_s.should =~ /^\d{4}$/
    end

    it "can boot non-200 code servers" do
      RealWeb.start_server(unauthorized_config_ru).stop
    end

    it "accepts an alternate timeout" do
      expect { RealWeb.start_server(slow_config_ru, :timeout => 0.1).stop }.to raise_error(RealWeb::ServerUnreachable)
    end
  end
end
