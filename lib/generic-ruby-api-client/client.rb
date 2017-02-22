require 'forwardable'

module GenericRubyApiClient
  class Client

    extend Forwardable

    attr_reader :agent

    def_delegators :@agent, :host

    def initialize(params = {})
      params = params.with_indifferent_access
      @agent = agent_class.new(agent_params(params))
    end

    def cached_call(cache_key, force, proc)
      if configuration.caching_enabled?
        response = cache.fetch(cache_key, force: force, &proc)
        cache.delete(cache_key) unless response.successful?
        response
      else
        proc.call
      end
    end

    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new(
        namespace: "generic-ruby-api-client_cache", expires_in: configuration.expires_in)
    end

    def clear_cache
      cache.clear
    end

    private

    def agent_params(params)
      info = agent_init_attributes.map{ |key| Hash[key => lookup_or_config(params, key)] }
      info.reduce(:merge)
    end

    def lookup_or_config(params, key)
      params.fetch(key) { configuration.public_send(key) }
    end

    def configuration
      @configuration ||= namespace::Configuration
    end

    def agent_class
      @agent_class ||= namespace::Agent
    end

    def namespace
      @namespace ||= self.class.name.deconstantize.safe_constantize
    end

    def agent_init_attributes
      [:scheme, :host, :base_uri]
    end

  end
end
