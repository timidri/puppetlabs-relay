require_relative '../../util/http'
require_relative '../model'
require_relative '../job/schedule'

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
          # @param state_dir [String]
          # @param schedule [Job::Schedule]
          # @return [Model::Run]
          # @abstract
          def exec(run, state_dir, schedule) # rubocop:disable Lint/UnusedMethodArgument
            raise NotImplementedError
          end
        end
      end
    end
  end
end
