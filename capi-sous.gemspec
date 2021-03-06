# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capi/sous/version"

Gem::Specification.new do |s|
  s.name        = "capi-sous"
  s.version     = CapiSous::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paul Alexnader"]
  s.email       = ["me@phallguy.com"]
  s.homepage    = ""
  s.summary     = %q{Capistrano recipes}
  s.description = %q{Extend the Capistrano gem with these useful recipes}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "capi-sous"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = [
     "README.md"
  ]
  
  s.add_dependency "capistrano", ">= 2.5.9"
  s.add_dependency 'capistrano-fanfare'
  s.add_dependency 'rvm-capistrano'
end