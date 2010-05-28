require 'spec_helper'

describe RealWeb do
  def config_ru
    File.expand_path("../config.ru", __FILE__)
  end

  shared_examples_for "working server" do
    describe ".start_server" do
      before { @server = start_server }
      after { @server.stop }

      it "starts an accessible server" do
        # Rack::Client.get(@server.base_uri).body.should == "Hello World"
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
end
