PKG_FILES = ["CHANGELOG", "MIT-LICENSE", "Rakefile", "README.rdoc", "TODO", "lib/aasm/aasm.rb", "lib/aasm/event.rb", "lib/aasm/persistence/active_record_persistence.rb", "lib/aasm/persistence.rb", "lib/aasm/state.rb", "lib/aasm/state_machine.rb", "lib/aasm/state_transition.rb", "lib/aasm.rb", "doc/jamis.rb"]

Gem::Specification.new do |s|
  s.name = 'aasm'
  s.version = "2.1.1"
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
