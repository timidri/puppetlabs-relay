require 'puppet'

require_relative '../error'
require_relative 'scope'
require_relative 'state'

module PuppetX
  module Relay
    module Agent
      module Model
        class Run
          class MissingScopeError < PuppetX::Relay::Agent::Error; end

          class << self
            def from_h(hsh)
              hsh = hsh.dup

              hsh['scope'] = Scope.from_h(hsh['scope']) if hsh.key? 'scope'
              hsh['state'] = State.from_h(hsh['state']) if hsh.key? 'state'

              self.new(hsh)
            end
          end

          # @return [String]
          attr_reader :id

          # @return [String]
          attr_reader :environment

          # @return [Scope]
          attr_reader :scope

          # @return [Boolean]
          attr_reader :noop, :debug, :trace, :evaltrace

          # @return [State]
          attr_reader :state

          # @param opts [Hash]
          def initialize(opts)
            opts = defaults.merge(opts)

            raise MissingScopeError unless opts.key? 'scope'

            opts.each { |key, value| instance_variable_set("@#{key}", value) }
          end

          # @param state [State]
          # @return [self]
          def with_state(state)
            upd = self.dup
            upd.instance_variable_set(:@state, state)
            upd
          end

          # @return [String]
          def to_json(*args)
            {
              id: id,
              environment: environment,
              scope: scope,
              noop: noop,
              debug: debug,
              trace: trace,
              evaltrace: evaltrace,
              state: state,
            }.to_json(*args)
          end

          private

          def defaults
            {
              'environment' => Puppet[:environment],
              'noop' => false,
              'debug' => false,
              'trace' => false,
              'evaltrace' => false,
            }
          end
        end
      end
    end
  end
end
