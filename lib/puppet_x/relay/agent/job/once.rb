require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Job
        class Once < Base
          # @param delegate [Base]
          def initialize(delegate)
            @delegate = delegate
          end

          def handle(job)
            @delegate.handle(job)
          ensure
            job.disable
          end
        end
      end
    end
  end
end
