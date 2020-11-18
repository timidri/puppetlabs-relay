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
          # @param state_dir [String]
          def initialize(backend, work, state_dir, exec_interval: nil)
            @backend = backend
            @work = work
            @state_dir = state_dir
            @exec_interval = exec_interval || 15
          end

          def handle(_job)
            Puppet.notice(_('Retrieving list of pending runs'))

            @backend.relay_api.get_runs
                    .select { |run| run.state.status == :pending }
                    .each do |run|
                      task = Exec.new(@backend, run, File.join(@state_dir, run.id))
                      @work.add(task, @exec_interval)
                    end
          rescue Net::HTTPError => e
            Puppet.warning(_('Failed to retrieve list of pending runs: %{e} (retrying)') % { e: e })
          end
        end
      end
    end
  end
end
