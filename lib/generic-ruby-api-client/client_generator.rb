require 'active_model'

module GenericRubyApiClient
  class ClientGenerator

    include ActiveModel::Validations

    attr_accessor :klass_name, :path_prefix, :additional_headers
    attr_writer   :calls_file, :custom_attributes, :additional_http_query_params, :gem_name

    validates :klass_name, :calls_file, presence: true
    validate :ensure_klass_name_constantizable
    validate :ensure_calls_file_exists
    validate :ensure_custom_attributes_is_an_array
    validate :ensure_path_prefix_validity, :if => "path_prefix.present?"

    def self.generate_client_library
      generator_instance = new
      yield(generator_instance)
      unless generator_instance.generate_client_library
        raise StandardError, generator_instance.errors.messages
      end
    end

    def generate_client_library
      return false unless valid?
      configuation_module
      client_class
      agent_class
      true
    end

    def namespace
      return @generic_namespace if @generic_namespace.present?
      if Object.const_defined?(klass_name)
        @generic_namespace = Object.const_get(klass_name)
      else
        @generic_namespace = Object.const_set(klass_name, Module.new)
      end

      @generic_namespace.module_exec do
        def self.configure
          yield(self::Configuration)
        end
      end
      @generic_namespace
    end

    def client_class
      return @client_class if @client_class.present?
      @client_class = namespace.const_set "Client", Class.new(Client)
      @client_class.include(calls_module)
      @client_class.class_eval(<<-RUBY)
        def agent_init_attributes
          super + #{agent_attributes}
        end
      RUBY
      @client_class
    end

    def configuation_module
      return @configuation_module if @configuation_module.present?
      @configuation_module = namespace.const_set "Configuration", Module.new
      @configuation_module.module_eval(<<-RUBY)
        include GenericConfiguration
        class << self
          attr_accessor *#{agent_attributes}
        end
      RUBY
      @configuation_module
    end

    def calls_module
      return @calls_module if @calls_module.present?
      require File.join(File.dirname(calls_file), File.basename(calls_file))
      @calls_module = "#{klass_name}::Calls".safe_constantize
    end

    def agent_class
      return @agent_class if @agent_class.present?
      @agent_class = namespace.const_set "Agent", Class.new(Agent)
      @agent_class.class_exec(custom_agent_params) do |custom_agent_params|
        attr_accessor *custom_agent_params[:custom_attributes]         if custom_agent_params[:custom_attributes].any?
        attr_accessor :proxy_uri                                       if custom_agent_params[:allow_http_proxy]
        validates_presence_of *custom_agent_params[:custom_attributes] if custom_agent_params[:custom_attributes].any?
        default_timeout custom_agent_params[:timeout] if custom_agent_params[:timeout].present?

        const_set(:PATH_PREFIX, custom_agent_params[:prefix])
        def path_prefix
          if self.class::PATH_PREFIX.present?
            self.class::PATH_PREFIX.gsub(/:(\w+)/){|match| send($1)}
          end
        end

        const_set(:ADDITIONAL_HEADERS, custom_agent_params[:additional_headers])
        def headers
          if self.class::ADDITIONAL_HEADERS.present?
            self.class::ADDITIONAL_HEADERS.each do |k,v|
              self.class::ADDITIONAL_HEADERS[k] = v.gsub(/:(\w+)/){|match| send($1)}
            end
            super.merge(self.class::ADDITIONAL_HEADERS)
          else
            super
          end
        end

        if custom_agent_params[:allow_http_proxy]
          def http_proxy
            if proxy_uri.present?
              uri = URI('http://' + proxy_uri) if !proxy_uri.include? 'http'
                {
                http_proxyaddr: uri.host,
                http_proxyport: uri.port,
                http_proxyuser: uri.user,
                http_proxypass: uri.password
              }
            else
              {}
            end
          end

          def http_options
            super.merge(http_proxy)
          end
        end

        if custom_agent_params[:additional_http_query_params].any?
          const_set(:ADDITIONAL_HTTP_QUERY_PARAMS, custom_agent_params[:additional_http_query_params])
          def additional_fields
            Hash[self.class::ADDITIONAL_HTTP_QUERY_PARAMS.map do |attribute|
              [attribute[:key],send(attribute[:value])]
            end]
          end
        end
      end
      @agent_class
    end

    def custom_agent_params
      {
        prefix: path_prefix,
        custom_attributes: custom_attributes,
        additional_http_query_params: additional_http_query_params,
        additional_headers: additional_headers,
        allow_http_proxy: allow_http_proxy?,
        timeout: timeout
      }
    end

    def calls_file
      @calls_file ||= File.join(gem_name, 'calls.rb')
    end

    def custom_attributes
      (@custom_attributes || []).map(&:to_sym)
    end

    def agent_attributes
      custom_attributes + (allow_http_proxy? ? [:proxy_uri] : [])
    end

    def additional_http_query_params
      (@additional_http_query_params || []).map(&:with_indifferent_access)
    end

    def gem_name
      @gem_name ||= dasherize_name? ? klass_name.underscore.dasherize : klass_name.underscore
    end

    def full_path_directory_name
      Gem::Specification.find_by_name(gem_name).gem_dir
    end

    def dasherize_name?
      !(@dasherize_name == false)
    end

    def allow_http_proxy!
      @allow_http_proxy = true
    end

    def allow_http_proxy?
      @allow_http_proxy == true
    end

    def timeout
      @timeout_seconds
    end

    def timeout=(timeout_seconds)
      @timeout_seconds = timeout_seconds
    end

    def dasherize_name!
      @dasherize = true
    end

    def underscore_name!
      @dasherize = false
    end

    def underscore_name?
      !dasherize_name?
    end

    def ensure_klass_name_constantizable
      errors.add(:klass_name, "cannot constantize") unless klass_name_constantizable?
    end

    def klass_name_constantizable?
      return false unless klass_name.present?
      Object.const_defined?(klass_name)
      true
    rescue NameError => e
      false
    end

    def ensure_calls_file_exists
      errors.add(:call_file, "file missing -- Looked here #{File.join(full_path_directory_name,'lib',calls_file)}") unless calls_file_exists?
    end

    def calls_file_exists?
      calls_file.present? && File.exist?(File.join(full_path_directory_name,'lib',calls_file))
    end

    def ensure_custom_attributes_is_an_array
      errors.add(:custom_attributes, "must be an array") unless custom_attributes.is_a? Array
    end

    def ensure_path_prefix_validity
      errors.add(:path_prefix, "embedded attributes don't match custom attributes") unless path_prefix_variables_match_custom_attributes?
    end

    def path_prefix_variables_match_custom_attributes?
      (path_prefix.scan(/:(\w+)/).flatten.map(&:to_sym) - custom_attributes).empty?
    end

  end
end
