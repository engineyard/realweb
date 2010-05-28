require 'bundler'
require 'rake/gempackagetask'
Bundler.require(:default, :test)

@spec = Gem::Specification.new do |s|
  s.name = "realweb"
  s.version = "0.1.0"
  s.summary = "Easily runs a rack app for tests that hit web APIs"
  s.description = s.summary
  s.has_rdoc = false
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.authors = ["Ben Burkert", "Martin Emde", "Sam Merritt"]
  s.email = "cloud-engineering@engineyard.com"
  s.homepage = "http://github.com/engineyard/realweb"

  bundle = Bundler::Definition.from_gemfile('Gemfile')
  bundle.dependencies.each do |dep|
    s.add_dependency(dep.name, dep.requirement.to_s) if dep.groups.include?(:runtime)
  end

  s.require_path = 'lib'
  s.files = Dir['{lib}/**/*']
end

Rake::GemPackageTask.new(@spec) do |pkg|
  pkg.gem_spec = @spec
end

require 'spec/rake/spectask'
desc "Run unit specifications"
Spec::Rake::SpecTask.new do |spec|
  spec.spec_opts << %w(-fs --color)
  spec.spec_opts << '--loadby' << 'random'
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec
