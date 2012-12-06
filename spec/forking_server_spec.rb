require 'spec_helper'

describe RealWeb::ForkingServer do
  subject { described_class.new(config_ru) }

  it "finds a port" do
    subject.port.should_not be_nil
  end

  it "retains the same port after it's found one" do
    subject.port.should == subject.port
  end

  it "is not running when newly created" do
    subject.should_not be_running
  end
end
