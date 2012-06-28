require 'spec_helper'

describe RealWeb::ForkingServer do
  def config_ru
    File.expand_path("../config.ru", __FILE__)
  end

  let(:server) { described_class.new(config_ru) }

  it "finds a port" do
    server.port.should_not be_nil
  end

  it "retains the same port after it's found one" do
    server.port.should == server.port
  end

  it "is not running when newly created" do
    server.should_not be_running
  end
end
