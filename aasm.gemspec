# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aasm/version"

Gem::Specification.new do |s|
  s.name        = "aasm"
  s.version     = AASM::VERSION
  s.authors     = ["Scott Barron", "Scott Petersen", "Travis Tilley", "Thorsten Böttger"]
  s.email       = %q{scott@elitists.net, ttilley@gmail.com}
  s.homepage    = %q{http://rubyist.github.com/aasm/}
  s.summary     = %q{State machine mixin for Ruby objects}
  s.description = %q{AASM is a continuation of the acts as state machine rails plugin, built for plain Ruby objects.}

  s.add_dependency             'activerecord'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sdoc'
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'minitest'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
