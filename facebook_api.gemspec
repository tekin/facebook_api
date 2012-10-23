# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "facebook_api/version"

Gem::Specification.new do |s|
  s.name = "facebook_api"
  s.version = FacebookApi::VERSION
  s.authors = ["Tekin Suleyman"]
  s.email = "tekin@tekin.co.uk"
  s.homepage = "https://github.com/tekin/facebook_api"
  s.summary     = "A simple, lightweight Ruby library for accessing the Facebook REST API"
  s.description = "A simple, lightweight Ruby library for accessing the Facebook REST API. Currently used in Facebook Connect applications, but could easily be extended for use in canvas applications."

  s.rubyforge_project = 'facebook_api'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency      "rest-client", ["~> 1.6.1"]
  s.add_runtime_dependency      "oauth2", ["~> 0.5.0"]
  s.add_development_dependency  "rake", ["~> 0.9.2"]
  s.add_development_dependency  "tzinfo", ["~> 0.3.29"]

  s.add_development_dependency  "test-unit", [">= 0"]
  s.add_development_dependency  "activesupport", [">= 3.2"]
  s.add_development_dependency  "shoulda", ["~> 2.11.3"]
  s.add_development_dependency  "mocha", ["~> 0.9.10"]
  s.add_development_dependency  "webmock", ["~> 1.6.1"]
end
