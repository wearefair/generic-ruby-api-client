require 'rubygems'
require 'bundler/setup'
require 'generic-ruby-api-client'
require 'shoulda-matchers'
require 'webmock/rspec'
require 'vcr'
require 'timecop'

VCR.configure do |config|
  config.cassette_library_dir = "vcr_cassettes"
  config.hook_into :webmock
end


Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
  end
end

RSpec.configure do |config|
  config.order = 'random'
  config.color = true
  config.add_formatter 'documentation'
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.before(:each) do |example|
  end
end

def mock_client_generator_configurations
  allow_any_instance_of(GenericRubyApiClient::ClientGenerator).to receive(:full_path_directory_name).and_return(Dir.pwd + '/spec/regression')
  allow_any_instance_of(GenericRubyApiClient::ClientGenerator).to receive(:calls_module).and_return(NewService::Calls)
end
