# Copyright 2008 Scott Barron (scott@elitists.net)
# All rights reserved

# This file may be distributed under an MIT style license.
# See MIT-LICENSE for details.

begin
  require 'rubygems'
  require 'rake/gempackagetask'
  require 'rake/testtask'
  require 'rake/rdoctask'
  require 'spec/rake/spectask'
rescue Exception
  nil
end

if `ruby -Ilib -rversion -e "print AASM::VERSION::STRING"` =~ /([0-9.]+)$/
  CURRENT_VERSION = $1
else
  CURRENT_VERSION = '0.0.0'
end
$package_version = CURRENT_VERSION

PKG_FILES = FileList['[A-Z]*',
'lib/**/*.rb',
'doc/**/*'
]

desc 'Generate documentation for the acts as state machine plugin.'
rd = Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'html'
  rdoc.template = 'doc/jamis.rb'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AASM'
  rdoc.options << '--line-numbers' << '--inline-source' <<  '--main' << 'README.rdoc' << '--title' << 'AASM'
  rdoc.rdoc_files.include('README.rdoc', 'MIT-LICENSE', 'TODO', 'CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
end

if !defined?(Gem)
  puts "Package target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    s.name = 'aasm'
    s.version = $package_version
    s.summary = 'State machine mixin for Ruby objects'
    s.description = <<-EOF
    AASM is a continuation of the acts as state machine rails plugin, built for plain Ruby objects.
    EOF
    s.files = PKG_FILES.to_a
    s.require_path = 'lib'
    s.has_rdoc = true
    s.extra_rdoc_files = rd.rdoc_files.reject {|fn| fn =~ /\.rb$/}.to_a
    s.rdoc_options = rd.options

    s.author = 'Scott Barron'
    s.email = 'scott@elitists.net'
    s.homepage = 'http://rubyi.st/aasm'
  end

  package_task = Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end

if !defined?(Spec)
  puts "spec and cruise targets require RSpec"
else
  desc "Run all examples with RCov"
  Spec::Rake::SpecTask.new('cruise') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--exclude', 'Library']
  end

  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = false
    t.spec_opts = ['-cfs']
  end
end

if !defined?(Gem)
  puts "Package target requires RubyGEMs"
else
  desc "sudo gem uninstall aasm && rake gem && sudo gem install pkg/aasm-3.0.0.gem"
  task :reinstall do
    puts `sudo gem uninstall aasm && rake gem && sudo gem install pkg/aasm-3.0.0.gem`
  end
end

task :default => [:spec]
