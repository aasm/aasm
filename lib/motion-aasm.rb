unless defined?(Motion::Project::App)
  raise "This must be required from within a RubyMotion Rakefile"
end

file_dependencies = {
  'aasm/aasm.rb' => ['aasm/persistence.rb'],
  'aasm/persistence.rb' => ['aasm/persistence/plain_persistence.rb', 'aasm/persistence/core_data_query_persistence.rb'],
  'aasm/persistence/base.rb' => ['aasm/base.rb'],
  'aasm/persistence/core_data_query_persistence.rb' => ['aasm/persistence/base.rb']
}

exclude_files = [
  'aasm/rspec.*',
  'aasm/minitest.*',
  'aasm/minitest_spec.*',
  'aasm/persistence/active_record_persistence.rb',
  'aasm/persistence/dynamoid_persistence.rb',
  'aasm/persistence/mongoid_persistence.rb',
  'aasm/persistence/no_brainer_persistence.rb',
  'aasm/persistence/sequel_persistence.rb',
  'aasm/persistence/redis_persistence.rb'
]

Motion::Project::App.setup do |app|
  parent = File.expand_path File.dirname(__FILE__)

  app.files.unshift Dir.glob(File.join(parent, "aasm/**/*.rb")).reject { |file| exclude_files.any? { |exclude| file.match(exclude) } }

  app.files_dependencies file_dependencies.inject({}, &->(file_dependencies, (file, *dependencies)) do
    file = File.join(parent, file)
    dependencies = dependencies.flatten(1).map do |dependency|
      File.join(parent, dependency)
    end

    file_dependencies.merge({ file => dependencies })
  end)
end
