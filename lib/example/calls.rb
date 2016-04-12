module Example
  module Calls

    ### CACHED CALLS

    def data_sources(force: false)
      proc = Proc.new { agent.fetch(action: "data_sources") }
      cached_call("data_sources", force, proc)
    end

    def scorable_types(force: false)
      proc = Proc.new { agent.fetch(action: "scorables") }
      cached_call("scorables", force, proc)
    end

    def current_model_versions(force: false)
      proc = Proc.new { agent.fetch(action: "current_model_versions") }
      cached_call("current_model_versions", force, proc)
    end

    def list_models(force: false)
      proc = Proc.new { agent.fetch(action: "list_models") }
      cached_call("list_models", force, proc)
    end

    def step_1_business_rules(force: false)
      proc = Proc.new { agent.fetch(action: "step_1_business_rules") }
      cached_call("step_1_business_rules", force, proc)
    end

    ### NON-CACHED CALLS

    def decision_information(model_version:, loan_ids:, scores:, fields: nil)
      loan_ids = loan_ids.join(",") if loan_ids.is_a?(Array)
      scores    = scores.join(",") if scores.is_a?(Array)
      params = {
        model_version: model_version,
        loan_id: loan_ids,
        score: scores
      }
      params[:fields] = fields.join(",") if fields.present?
      generic_payload_request("decision_information", params)
    end

    def is_letter(ids:, type: 'loan', mode: 'now')
      ids = ids.join(",") if ids.is_a?(Array)
      ensure_inclusion!(type, ['customer','loan'])
      ensure_inclusion!(mode, ['now','all','count','when'])
      params = {
        ids: ids,
        mode: mode,
        type: type
      }
      generic_payload_request("is_letter", params)
    end

    def to_credit_decision(ids:, type: 'loan')
      ids = ids.join(",") if ids.is_a?(Array)
      params = {
        type: type,
        ids: ids
      }
      generic_payload_request("to_credit_decision", params)
    end

    def is_returning(ids:, type: 'loan')
      ensure_inclusion!(type, ['customer','loan'])
      params = {
        ids: ids.join(","),
        type: type
      }
      generic_payload_request("is_returning", params)
    end

    def can_return(ids:, type: 'loan')
      ensure_inclusion!(type, ['customer','loan'])
      params = { ids: ids.join(",") }
      generic_payload_request("can_return", params)
    end

    def is_or_can_be_returning(ids:, type: 'loan')
      ensure_inclusion!(type, ['customer','loan'])
      params = { ids: ids.join(",") }
      generic_payload_request("is_or_can_be_returning", params)
    end

    def has_returned(ids:, type: 'loan')
      ensure_inclusion!(type, ['customer','loan'])
      params = { ids: ids.join(",") }
      generic_payload_request("has_returned", params)
    end

    def fetch_previous_loans(ids:)
      params = { ids: ids.join(",") }
      generic_payload_request("fetch_previous_loans", params)
    end

    def request_collections_scoring
    end

    def run_validation(ids:, id_type:, model_type:, model_version:, model_params:, rserver:)
      #' @param version character. Model version. Version names starting with 'virtual/' are treated as virtual models
      #' @param ids integer. Ids to use for model validation.
      #' @param id_type character. Scorable type. Defaults to loan.
      #' @param rserver character. URL of rserver to use for validation.
      #'    Defaults to analytics-dev with a warning if it is not set.
      ensure_inclusion!(model_type, ['virtual', 'deployed'])
      # params = {
      #   ids:, #scorable ids array
      #   id_type: , #scorable type
      #   model_type:,
      #   model_version: ,
      #   model_params: ,
      #   rserver:
      # }
    end

    def virtual_model_score
    end

    def create_cst_set
    end

    def run_cst
    end

    def get_cst_s3_key
    end

    def debug_microvariable_data
    end

    def has_data_sources
    end

    def loan_ids
      agent.fetch(action: "loan_ids")
    end

    def lead_ids
      agent.fetch(action: "lead_ids")
    end

    def batch_source(ids:, type:, source_type:, source_args: {})
      params = {
        type: type,
        ids: ids,
        source_type: source_type,
        source_args: source_args
      }
      generic_payload_request("batch_source", params)
    end

    private

    def generic_payload_request(action, payload)
      params = {
        action: action,
        fields: {
          payload: payload
        },
        :verb => :post
      }
      agent.fetch(params)
    end

    def ensure_inclusion!(value, list)
      raise ArgumentError, "#{value} must be in #{list}" unless list.include?(value)
    end

  end
end
