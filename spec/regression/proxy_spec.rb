require 'spec_helper'
require_relative 'lib/new-service/calls'
require 'socket'

describe GenericRubyApiClient::ClientGenerator do
  let(:client_generator) { GenericRubyApiClient::ClientGenerator.new() }
  context "wWhen generating a client via client generator" do
    before do
      mock_client_generator_configurations
    end

    it "should return proxy ip when using a proxy" do
      VCR.use_cassette('get_proxy_ip') do
        GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
          client.klass_name = "NewService"
          client.path_prefix = ""
          client.custom_attributes = [:api_key]
          client.additional_headers = { }
          client.allow_http_proxy!
        end

        NewService.configure do |config|
          config.host      = "ip.quotaguard.com"
          config.proxy_uri = "quotaguard5247:347ade991789@us-east-static-01.quotaguard.com:9293"
          config.api_key   = "api_key"
          config.scheme    = "http"
        end

        resp = NewService::Client.new()
        expect(resp.get.response).to eq({"ip"=>"50.17.160.202"} || {"ip"=>"52.86.18.14"} )
      end
    end

    it "should return local ip when not using a proxy" do
      VCR.use_cassette('get_ip') do
        GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
          client.klass_name = "NewService"
          client.path_prefix = ""
          client.custom_attributes = [:api_key]
          client.additional_headers = { }
        end

        NewService.configure do |config|
          config.host      = "ip.quotaguard.com"
          config.api_key   = "api_key"
          config.scheme    = "http"
        end

        resp = NewService::Client.new()
        expect(resp.get.response).to eq({"ip"=>"38.88.222.50"} )
      end
    end

    it "should return local ip when proxy is enable but not used" do
      VCR.use_cassette('get_ip_proxy_enabled_but_not_used') do
        GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
          client.klass_name = "NewService"
          client.path_prefix = ""
          client.custom_attributes = [:api_key]
          client.additional_headers = { }
          client.allow_http_proxy!
        end

        NewService.configure do |config|
          config.host      = "ip.quotaguard.com"
          config.api_key   = "api_key"
          config.scheme    = "http"
        end

        resp = NewService::Client.new()
        expect(resp.get.response).to eq({"ip"=>"38.88.222.50"} )
      end
    end

    it "should return error when proxy is disabled but proxy_uri is configured " do
      GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
        client.klass_name         = "NewService"
        client.path_prefix        = ""
        client.custom_attributes  = [:api_key]
        client.additional_headers = {}
      end

      expect {
        NewService.configure do |config|
          config.host      = "ip.quotaguard.com"
          config.api_key   = "api_key"
          config.proxy_uri = "quotaguard5247:347ade991789@us-east-static-01.quotaguard.com:9293"
          config.scheme    = "http"
        end
      }.to raise_error(NoMethodError, "undefined method `proxy_uri=' for NewService::Configuration:Module")
    end

    it "should return proxy ip when using a proxy with http" do
      VCR.use_cassette('get_proxy_ip_with_http') do
        GenericRubyApiClient::ClientGenerator.generate_client_library do |client|
          client.klass_name = "NewService"
          client.path_prefix = ""
          client.custom_attributes = [:api_key]
          client.additional_headers = { }
          client.allow_http_proxy!
        end

        NewService.configure do |config|
          config.host      = "ip.quotaguard.com"
          config.api_key   = "api_key"
          config.scheme    = "http"
        end

        resp = NewService::Client.new(proxy_uri: "http://quotaguard5247:347ade991789@us-east-static-01.quotaguard.com:9293")
        expect(resp.get.response).to eq({"ip"=>"50.17.160.202"} || {"ip"=>"52.86.18.14"} )
      end
    end

  end
end