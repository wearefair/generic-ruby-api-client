module NewService
  module Calls
    def get
      agent.fetch(action: "", verb: :get)
    end
  end
end
