require 'active_model/errors'

module GenericRubyApiClient
  class Response
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    attr_accessor :status, :response, :message, :timestamp
    attr_reader   :errors

    def initialize(params = {})
      @status    = params[:status]
      @response  = params[:response]
      @message   = params[:message]
      @timestamp = params[:timestamp]
      @errors    = ActiveModel::Errors.new(self)
    end

    def successful?
      !(/^2\d\d$/.match(status.to_s).nil?) && errors.empty?
    end

    def read_attribute_for_validation(attr)
      attr
    end

  end
end
