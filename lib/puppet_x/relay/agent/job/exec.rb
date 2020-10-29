require 'puppet'

require_relative '../backend'
require_relative '../model'
require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Job
        class Exec < Base
          # @param backend [Backend::Base]
          # @param run [Model::Run]
          def initialize(backend, run)
            @backend = backend
            @run = run
          end

          def handle(job)
            if @pid.nil?
              @pid = fork { handle_child }
            end

            Process.wait(@pid, Process::WNOHANG | Process::WUNTRACED)
            if !$?.nil? && $?.exited?
              Puppet.notice(_('Run %{id} finished with exit code %{exitstatus}' % {id: @run.id, exitstatus: $?.exitstatus}))
              job.disable
            end
          end

          private

          def handle_child
            Puppet.notice(_('Starting run %{id}' % {id: @run.id}))
            if @backend.relay_api.post_accept_run(@run)
              @run = @backend.exec(@run)
            end
          end
        end
      end
    end
  end
end
