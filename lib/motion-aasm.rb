unless defined?(Motion::Project::App)
  raise "This must be required from within a RubyMotion Rakefile"
end

file_dependencies = {
  'aasm/persistence/base.rb' => ['aasm/base.rb']
}

exclude_files = [
  'rspec'
]

Motion::Project::App.setup do |app|
  parent = File.expand_path File.dirname(__FILE__)

  app.files += Dir.glob(File.join(parent, "aasm/**/*.rb")).reject { |file| exclude_files.any? { |exclude| file.match(exclude) } }

  app.files_dependencies file_dependencies.inject({}, &->(file_dependencies, (file, *dependencies)) do
    file = File.join(parent, file)
    dependencies = dependencies.flatten(1).map do |dependency|
      File.join(parent, dependency)
    end

    file_dependencies.merge({ file => dependencies })
  end)
end
