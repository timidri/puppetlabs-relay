require 'puppet'

require_relative '../error'
require_relative 'scope'
require_relative 'state'

module PuppetX
  module Relay
    module Agent
      module Model
        module Stateful
          # @return [String]
          attr_reader :id

          # @return [State]
          attr_reader :state

          # @param state [State]
          # @return [self]
          def with_state(state)
            upd = dup
            upd.instance_variable_set(:@state, state)
            upd
          end
        end
      end
    end
  end
end
