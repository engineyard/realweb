$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require "realweb"
require 'timeout'

module FixtureHelpers
  def fixtures_root
    File.expand_path("fixtures", File.dirname(__FILE__))
  end

  def config_ru
    File.join(fixtures_root, "config.ru")
  end

  def unauthorized_config_ru
    File.join(fixtures_root, "unauthorized_config.ru")
  end

  def slow_config_ru
    File.join(fixtures_root, "slow_config.ru")
  end

  def debug?
    ENV['DEBUG']
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
