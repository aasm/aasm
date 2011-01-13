require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

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
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new(:rcov_shoulda) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['-cfs']
end

RSpec::Core::RakeTask.new(:rcov_rspec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'reek/rake/task'
Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.verbose = false
  t.source_files = 'lib/**/*.rb'
end

require 'roodi'
require 'roodi_task'
RoodiTask.new do |t|
  t.verbose = false
end

task :default => :test

require 'rake/rdoctask'
require 'sdoc'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "aasm #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')

  rdoc.options << '--fmt' << 'shtml'
  rdoc.template = 'direct'
end