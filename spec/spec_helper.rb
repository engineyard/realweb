$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require "realweb"
require 'timeout'
