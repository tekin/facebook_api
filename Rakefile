require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
end

task :default => ["test"]

spec = Gem::Specification.new do |s|

  s.name              = "facebook_api"
  s.version           = "0.1.3"
  s.summary           = "A simple, lightweight Ruby library for accessing the Facebook API"
  s.author            = "Tekin Suleyman"
  s.email             = "tekin@tekin.co.uk"
  s.homepage          = "http://tekin.co.uk"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README.rdoc)
  s.rdoc_options      = %w(--main README.rdoc)

  s.files             = %w(LICENSE README.rdoc) + Dir.glob("{test,lib/**/*}")
  s.require_paths     = ["lib"]

  s.add_dependency("rest-client", '> 1.4.2')

  s.add_development_dependency("test-unit")
  s.add_development_dependency("shoulda")
  s.add_development_dependency("mocha")
  s.add_development_dependency("webmock")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

task :package => :gemspec

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
