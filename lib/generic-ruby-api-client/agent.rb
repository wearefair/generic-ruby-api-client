require 'httparty'
require 'addressable/uri'
require 'json'
require 'active_model'

module GenericRubyApiClient
  class Agent

    AllowedHttpVerbs = [:get, :put, :post]

    include ActiveModel::Validations

    attr_accessor :host, :scheme #, :api_key

    validates :host, :scheme, :presence => true #, :api_key

    def initialize(params = {})
      params.each do |k,v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
      # self.host        = params[:host]
      # self.scheme      = params[:scheme]
      # self.api_key     = params[:api_key]
    end

    def fetch(params = {})
      resp = GenericRubyApiClient::Response.new
      errors.each{|attribute, error| resp.errors.add(attribute, error)} unless valid?

      verb = params.fetch(:verb, :get)
      resp.errors.add(:http, "http verb must be in #{AllowedHttpVerbs}") unless AllowedHttpVerbs.include? verb.to_sym

      if params.has_key?(:action)
        action = url_path(action: params.fetch(:action))
      else
        resp.errors.add(:action, "url path required")
      end

      return resp if resp.errors.any?

      should_parse = params.fetch(:should_parse, true)
      uri          = uri(action)
      fields       = params.fetch(:fields, {}).merge(additional_fields)
      options      = http_options

      http_request(resp, verb, uri, options, fields, should_parse)
    end

    private

    def uri(action)
      Addressable::URI.new({
        :scheme => scheme,
        :host   => host,
        :path   => action
      })
    end

    def http_options
      {headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'}}
    end

    def http_request(response, verb, uri, options, fields, should_parse)
      begin
        if verb == :get
          http = HTTParty.get(uri, options.merge({ query: fields }))
        else
          http = HTTParty.send(verb, uri, options.merge({ body: fields.to_json }))
        end
        response.status    = http.code
        response.message   = http.message
        response.timestamp = Time.now.utc
        set_body(response, http.body, should_parse)
        add_errors(response)
      rescue OpenSSL::SSL::SSLError
        response.errors.add(:ssl, "OpenSSL::SSL::SSLError - Unable to communicate with #{uri.scheme}://#{uri.host}/ over SSL")
      rescue Errno::ECONNREFUSED
        response.errors.add(:socket, "Errno::ECONNREFUSED - Connection to #{uri.scheme}://#{uri.host}/ was refused")
      rescue Errno::ETIMEDOUT
        response.errors.add(:socket, "Errno::ETIMEDOUT - Timed out connecting to #{uri.scheme}://#{uri.host}/")
      rescue Errno::EHOSTDOWN
        response.errors.add(:socket, "Errno::EHOSTDOWN - The host at #{uri.scheme}://#{uri.host}/ is not responding to requests")
      rescue Errno::EHOSTUNREACH
        response.errors.add(:socket, "Errno::EHOSTUNREACH - Possible network issue communicating with #{uri.scheme}://#{uri.host}/")
      rescue SocketError
        response.errors.add(:socket, "SocketError - Couldn't make sense of the host destination #{uri.scheme}://#{uri.host}/")
      rescue JSON::ParserError
        response.errors.add(:json, "JSON::ParserError - The host at #{uri.scheme}://#{uri.host}/ returned a non-JSON response, body: #{http.body}")
      end
      response
    end

    def add_errors(response)
      if response.response.is_a?(Hash) && (errors = (response.response[:errors] || response.response[:error]))
        case errors
        when Hash
          errors.each { |k,v| response.errors.add(k, v) }
        when Array
          errors.each { |v| response.errors.add(:base, v) }
        when String
          response.errors.add(:base, errors)
        end
      end
      response.errors.add(:timeout, "Heroku timeout") if response.status == 503
    end

    def set_body(response, body, should_parse)
      if should_parse && response.status != 503
        parsed = JSON.parse(body)
        response.response =  parsed.is_a?(Hash) ? parsed.with_indifferent_access : parsed
      else
        response.response = body
      end
    end

    def namespace
      @namespace ||= self.class.name.deconstantize.safe_constantize
    end

    def url_path(action:)
      path_prefix ? File.join(path_prefix, action) : action
    end

    def additional_fields
      {}
    end

  end
end
