require_relative '../backend'
require_relative 'base'
require_relative 'work'

module PuppetX
  module Relay
    module Agent
      module Job
        class Dispatch < Base
          # @param backend [Backend::Base]
          # @param work [Work]
          def initialize(backend, work, exec_interval_s: 2)
            @backend = backend
            @work = work
            @exec_interval_s = exec_interval_s
          end

          def handle(job)
            Puppet.notice(_('Retrieving list of pending runs'))

            @backend.relay_api.get_runs
              .select { |run| run.state.status == :pending }
              .each { |run| @work.add(Exec.new(@backend, run), @exec_interval_s) }
          end
        end
      end
    end
  end
end
