PKG_FILES = ["CHANGELOG", "MIT-LICENSE", "Rakefile", "README.rdoc", "TODO", "lib/aasm.rb", "lib/event.rb", "lib/persistence/active_record_persistence.rb", "lib/persistence.rb", "lib/state.rb", "lib/state_machine.rb", "lib/state_transition.rb", "doc/jamis.rb"]

Gem::Specification.new do |s|
  s.name = 'aasm'
  s.version = "2.1.0"
  s.summary = %q{State machine mixin for Ruby objects}
  s.description = %q{AASM is a continuation of the acts as state machine rails plugin, built for plain Ruby objects.}

  s.files = PKG_FILES
  s.require_paths = ["lib"]
  
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'MIT-LICENSE', 'TODO', 'CHANGELOG']
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.rdoc', '--title', 'AASM']

  s.authors = ["Scott Barron"]
  s.email = %q{scott@elitists.net}
  s.homepage = 'http://github.com/rubyist/aasm'
end
