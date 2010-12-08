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

  s.add_dependency("rest-client", '~> 1.6.1')
  s.add_dependency("oauth2", '~> 0.1.0')
  s.add_dependency("active_support", '~> 3.0.3')

  s.add_development_dependency("test-unit")
  s.add_development_dependency("shoulda", '~> 2.11.3')
  s.add_development_dependency("mocha", '~> 0.9.10')
  s.add_development_dependency("webmock", '~> 1.6.1')
  
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3")
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

desc 'Tag the repository in git with gem version number'
task :tag => [:gemspec, :package] do
  if `git diff --cached`.empty?
    if `git tag`.split("\n").include?("v#{spec.version}")
      raise "Version #{spec.version} has already been released"
    end
    `git add #{File.expand_path("../#{spec.name}.gemspec", __FILE__)}`
    `git commit -m "Released version #{spec.version}"`
    `git tag v#{spec.version}`
    `git push --tags`
    `git push`
  else
    raise "Unstaged changes still waiting to be committed"
  end
end

desc "Tag and publish the gem to rubygems.org"
task :publish => :tag do
  `gem push pkg/#{spec.name}-#{spec.version}.gem`
end
