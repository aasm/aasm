RSpec.configure do |config|
  config.before(:each) do
    allow_any_instance_of(Logger).to receive(:warn)
  end
end
