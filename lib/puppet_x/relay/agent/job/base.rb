require 'puppet'
require 'puppet/scheduler'

module PuppetX
  module Relay
    module Agent
      module Job
        class Base
          # @param job [Puppet::Scheduler::Job]
          # @abstract
          def handle(job) # rubocop:disable Lint/UnusedMethodArgument
            raise NotImplementedError
          end

          def to_job(interval)
            Puppet::Scheduler.create_job(interval) { |job| handle(job) }
          end
        end
      end
    end
  end
end
