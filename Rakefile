require 'bundler/setup'
require 'rake/gempackagetask'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run unit specifications"
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = %w(-fs --color)
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
