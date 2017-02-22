require 'active_support/concern'

module GenericRubyApiClient
  module GenericConfiguration
    extend ActiveSupport::Concern

    class_methods do
      def scheme
        @scheme
      end

      def scheme=(scheme)
        @scheme = scheme
      end

      def host=(host)
        @host = host
      end

      def host
        @host
      end

      def base_uri
        @base_uri
      end

      def base_uri=(base_uri)
        @base_uri=base_uri
      end

      def expires_in
        @expires_in ||= 3600
      end

      def caching_enabled?
        return false if(@use_caching == false)
        @use_caching ||= true
      end

      def enable_caching!
        @use_caching = true
      end

      def disable_caching!
        @use_caching = false
      end
    end
  end
end
