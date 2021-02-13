require 'puppet'

require_relative '../error'
require_relative 'state'
require_relative 'stateful'

module PuppetX
  module Relay
    module Agent
      module Model
        class PlanRun
          include Stateful

          class MissingNameError < PuppetX::Relay::Agent::Error; end

          class << self
            def from_h(hsh)
              hsh = hsh.dup
              hsh['state'] = State.from_h(hsh['state']) if hsh.key? 'state'
              new(hsh)
            end
          end

          # @return [String]
          attr_reader :environment

          # @return [String]
          attr_reader :name

          # @return [Hash]
          attr_reader :params

          # @param opts [Hash]
          def initialize(opts)
            opts = defaults.merge(opts)

            raise MissingNameError unless opts.key? 'name'

            opts.each { |key, value| instance_variable_set("@#{key}", value) }
          end

          # @return [String]
          def to_json(*args)
            {
              id: id,
              environment: environment,
              name: name,
              params: params,
              state: state,
            }.to_json(*args)
          end

          private

          def defaults
            {
              'environment' => Puppet[:environment],
              'params' => {},
            }
          end
        end
      end
    end
  end
end
