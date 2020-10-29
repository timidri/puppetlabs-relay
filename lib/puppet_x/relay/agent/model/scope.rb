require_relative '../error'

module PuppetX
  module Relay
    module Agent
      module Model
        class Scope
          class InvalidDefinitionError < PuppetX::Relay::Agent::Error; end
          class NotFoundError < PuppetX::Relay::Agent::Error; end

          @descendants = {}

          class << self
            def key
              name
                .split('::')[-1]
                .gsub(%r{(^|[^A-Z])([A-Z]+)}) do
                  if Regexp.last_match(1).empty?
                    Regexp.last_match(2).downcase
                  else
                    "#{Regexp.last_match(1)}_#{Regexp.last_match(2).downcase}"
                  end
                end
            end

            def inherited(klass)
              @descendants[klass.key] = klass
            end

            def from_h(hsh)
              raise InvalidDefinitionError, 'Scope must have exactly one item' unless hsh.length == 1

              key, value = hsh.shift
              raise NotFoundError, "Scope #{key.inspect} does not exist" unless @descendants.key? key

              @descendants[key].new value
            end
          end

          attr_reader :value

          def initialize(value)
            @value = value
          end

          def to_json(*args)
            { self.class.key => value }.to_json(*args)
          end

          class Nodes < Scope; end
          class Application < Scope; end
          class Query < Scope; end
          class NodeGroup < Scope; end
        end
      end
    end
  end
end
