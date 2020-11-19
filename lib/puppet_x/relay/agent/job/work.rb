require 'set'

require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Job
        class Work
          include Enumerable

          def initialize
            @jobs = Set.new.compare_by_identity
          end

          # @param item [Base]
          # @param interval [Integer]
          def add(item, interval = 0)
            elim_disabled
            @jobs << item.to_job(interval)
            self
          end

          def each(&block)
            elim_disabled
            @jobs.each(&block)
            self
          end

          private

          def elim_disabled
            @jobs.select! { |job| job.enabled? }
          end
        end
      end
    end
  end
end
