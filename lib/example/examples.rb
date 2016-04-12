require 'generic-ruby-api-client'

g = GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
  client.klass_name = "Example"
  client.path_prefix = "api/v1/:api_key"
  client.custom_attributes = [:api_key]
  client.additional_http_query_params = [
    {
      key: :api_key,
      value: :api_key
    }
  ]
end
g.configuation_module

g2 = GenericRubyApiClient::ClientGenerator.generate_client_library { |client| client.klass_name = "Example" } #GenericRubyApiClient" #AvantBasic"

c.send(:lookup_or_config,{}, :scheme)
