require 'generic-ruby-api-client'

g = GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
  client.klass_name = "Example"
  client.path_prefix = "api/v1/anything"
  client.custom_attributes = [:api_key]
  client.additional_headers = {'Api-Key' => ":api_key" }
end

c = Example::Client.new(host: "localhost:3000", scheme: 'http', api_key: '232323')
g.configuation_module

  client.additional_http_query_params = [
    {
      key: :api_key,
      value: :api_key
    }
  ]

g2 = GenericRubyApiClient::ClientGenerator.generate_client_library { |client| client.klass_name = "Example" } #GenericRubyApiClient" #AvantBasic"

c.send(:lookup_or_config,{}, :scheme)
