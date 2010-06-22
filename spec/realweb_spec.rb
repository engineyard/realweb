require 'spec_helper'

describe RealWeb do
  def config_ru
    File.expand_path("../config.ru", __FILE__)
  end

  def unauthorized_config_ru
    File.expand_path("../unauthorized_config.ru", __FILE__)
  end

  shared_examples_for "working server" do
    describe ".start_server" do
      before { @server = start_server }
      after { @server.stop }

      it "starts an accessible server" do
        open(@server.base_uri).read.should == "Hello World"
      end

      it "becomes inaccessible when stop is called" do
        @server.stop
        lambda { open(@server.base_uri) }.should raise_error(Errno::ECONNREFUSED)
      end
    end

    describe ".with_server" do
      it "starts an accessible server" do
        with_server do |server|
          open(server.base_uri).read.should == "Hello World"
        end
      end

      it "becomes inaccessible on block exit" do
        base_uri = nil
        with_server { |server| base_uri = server.base_uri }
        lambda { open(base_uri) }.should raise_error(Errno::ECONNREFUSED)
      end
    end
  end

  describe "InThreadServer" do
    def start_server
      RealWeb.start_server_in_thread(config_ru)
    end

    def with_server(&block)
      RealWeb.with_server_in_thread(config_ru, &block)
    end

    it_should_behave_like "working server"
  end

  describe "ForkingServer" do
    def start_server
      RealWeb.start_server_in_fork(config_ru)
    end

    def with_server(&block)
      RealWeb.with_server_in_fork(config_ru, &block)
    end

    it_should_behave_like "working server"
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
  end
end
