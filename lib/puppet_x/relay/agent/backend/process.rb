require 'puppet'
require 'puppet/util/lockfile'
require 'English'

require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Backend
        class Process < Base
          def exec(run, state_dir, schedule)
            statuses = []

            format_commands(run, state_dir).each_with_index do |cmd, n|
              lock = Puppet::Util::Lockfile.new(File.join(state_dir, "proc_#{n}.pid"))
              pid =
                if lock.locked?
                  Integer(lock.lock_data)
                else
                  fork { exec_child(lock, cmd) }
                end

              ::Process.wait(pid, ::Process::WNOHANG | ::Process::WUNTRACED)
              statuses << $CHILD_STATUS
            end

            new_state =
              if statuses.none?(&:nil?)
                run.state.to_complete(outcome: (statuses.all? { |s| s.exitstatus.zero? }) ? 'finished' : 'failed')
              else
                run.state.to_in_progress(schedule.next_update_before)
              end

            run.with_state(new_state)
          end

          protected

          # @abstract
          # @param run [Model::Stateful]
          # @param state_dir [String]
          # @return [Array<Array<String>>]
          def format_commands(run, state_dir) # rubocop:disable Lint/UnusedMethodArgument
            raise NotImplementedError
          end

          private

          def exec_child(lock, cmd)
            lock.lock(::Process.pid)
            Kernel.exec(*cmd)
          ensure
            lock.unlock
          end
        end
      end
    end
  end
end
