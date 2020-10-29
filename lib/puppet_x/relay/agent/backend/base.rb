require_relative '../../util/http'
require_relative '../model'

module PuppetX
  module Relay
    module Agent
      module Backend
        class Base
          # @return [Util::HTTP::RelayAPI]
          attr_reader :relay_api

          # @param relay_api [Util::HTTP::RelayAPI]
          def initialize(relay_api)
            @relay_api = relay_api
          end

          # @param run [Model::Run]
          # @return [Model::Run]
          def exec(run)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
