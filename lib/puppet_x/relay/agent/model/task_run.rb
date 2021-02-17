require 'puppet'

require_relative '../error'
require_relative 'scope'
require_relative 'state'
require_relative 'stateful'

module PuppetX
  module Relay
    module Agent
      module Model
        class TaskRun
          include Stateful

          class MissingScopeError < PuppetX::Relay::Agent::Error; end
          class MissingNameError < PuppetX::Relay::Agent::Error; end

          class << self
            def from_h(hsh)
              hsh = hsh.dup
              hsh['scope'] = Scope.from_h(hsh['scope']) if hsh.key? 'scope'
              hsh['state'] = State.from_h(hsh['state']) if hsh.key? 'state'
              new(hsh)
            end
          end

          # @return [String]
          attr_reader :environment

          # @return [Scope]
          attr_reader :scope

          # @return [String]
          attr_reader :name

          # @return [Hash]
          attr_reader :params

          # @return [Boolean]
          attr_reader :noop

          # @return [Array<Hash>]
          attr_reader :targets

          # @param opts [Hash]
          def initialize(opts)
            opts = defaults.merge(opts)

            raise MissingScopeError unless opts.key? 'scope'
            raise MissingNameError unless opts.key? 'name'

            opts.each { |key, value| instance_variable_set("@#{key}", value) }
          end

          # @return [String]
          def to_json(*args)
            {
              id: id,
              environment: environment,
              scope: scope,
              name: name,
              params: params,
              noop: noop,
              targets: targets,
              state: state,
            }.to_json(*args)
          end

          private

          def defaults
            {
              'environment' => Puppet[:environment],
              'params' => {},
              'noop' => false,
              'targets' => [],
            }
          end
        end
      end
    end
  end
end
