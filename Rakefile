require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run unit specifications"
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = %w[--color]
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :test => :spec
task :default => :spec

desc "Run specs and generate coverage report"
task :coverage => [:coverage_env, :spec]
task :coverage_env do
  ENV['COVERAGE'] = '1'
end
