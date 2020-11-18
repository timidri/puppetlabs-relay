require 'puppet'
require 'puppet/scheduler'

module PuppetX
  module Relay
    module Agent
      module Job
        class Schedule
          class << self
            # @param job [Puppet::Scheduler::Job]
            def from_scheduler_job(job)
              new(job.run_interval, first_run_at: job.start_time, last_run_at: job.last_run)
            end
          end

          # @return [Integer]
          attr_reader :interval

          # @return [Time]
          attr_reader :first_run_at, :last_run_at

          def initialize(interval, first_run_at: nil, last_run_at: nil)
            @interval = interval
            @first_run_at = first_run_at || Time.now
            @last_run_at = last_run_at || @first_run_at
          end

          # @return [Time]
          def next_run_at
            last_run_at + interval
          end

          # @return [Time]
          def next_update_before
            last_run_at + interval * 3
          end

          # @return [Integer]
          def elapsed
            last_run_at - first_run_at
          end
        end
      end
    end
  end
end
