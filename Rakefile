require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "aasm"
    gem.summary = %Q{State machine mixin for Ruby objects}
    gem.description = %Q{AASM is a continuation of the acts as state machine rails plugin, built for plain Ruby objects.}
    gem.homepage = "http://rubyist.github.com/aasm/"
    gem.authors = ["Scott Barron", "Scott Petersen", "Travis Tilley"]
    gem.email = "scott@elitists.net, ttilley@gmail.com"
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "shoulda"
    gem.add_development_dependency 'sdoc'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new(:rcov_shoulda) do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ['-cfs']
end

Spec::Rake::SpecTask.new(:rcov_rspec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :test => :check_dependencies
task :spec => :check_dependencies

begin
  require 'reek/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :test

begin
  require 'rake/rdoctask'
  require 'sdoc'
  Rake::RDocTask.new do |rdoc|
    if File.exist?('VERSION')
      version = File.read('VERSION')
    else
      version = ""
    end

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "aasm #{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')

    rdoc.options << '--fmt' << 'shtml'
    rdoc.template = 'direct'
  end
rescue LoadError
  puts "aasm makes use of the sdoc gem. Install it with: sudo gem install sdoc"
end

