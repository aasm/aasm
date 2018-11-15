# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aasm/version"

Gem::Specification.new do |s|
  s.name        = "aasm"
  s.version     = AASM::VERSION
  s.authors     = ["Thorsten Boettger", "Anil Maurya"]
  s.email       = %q{aasm@mt7.de, anilmaurya8dec@gmail.com}
  s.homepage    = %q{https://github.com/aasm/aasm}
  s.summary     = %q{State machine mixin for Ruby objects}
  s.description = %q{AASM is a continuation of the acts-as-state-machine rails plugin, built for plain Ruby objects.}
  s.date        = Time.now
  s.licenses    = ["MIT"]

  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'concurrent-ruby', '~> 1.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'sdoc'
  s.add_development_dependency 'rspec', ">= 3"
  s.add_development_dependency 'generator_spec'
  s.add_development_dependency 'appraisal'

  # debugging
  # s.add_development_dependency 'debugger'
  s.add_development_dependency 'pry'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
