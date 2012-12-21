Gem::Specification.new do |s|
  s.name = "realweb"
  s.version = "1.0.1"
  s.summary = "Easily runs a rack app for tests that hit web APIs"
  s.description = s.summary
  s.has_rdoc = false
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.authors = ["Ben Burkert", "Martin Emde", "Sam Merritt"]
  s.email = "cloud-engineering@engineyard.com"
  s.homepage = "http://github.com/engineyard/realweb"

  s.add_runtime_dependency "rack", '>=1.3.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~>2.0'
  s.add_development_dependency 'puma'
  s.add_development_dependency 'simplecov'

  s.require_path = 'lib'
  s.files = Dir['{lib}/**/*']
end
