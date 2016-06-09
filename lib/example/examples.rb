require 'generic-ruby-api-client'

GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
  client.klass_name = "Example"
  client.path_prefix = "api/v1/anything"
  client.custom_attributes = [:api_key]
  client.additional_headers = {'Api-Key' => ":api_key" }
  client.allow_http_proxy!
end

c = Example::Client.new(host: "localhost:3000", scheme: 'http', api_key: '232323')
