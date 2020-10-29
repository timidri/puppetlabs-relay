require 'puppet'
require 'puppet/scheduler'

require_relative 'job/base'
require_relative 'job/dispatch'
require_relative 'job/exec'
require_relative 'job/work'
require_relative 'backend'

module PuppetX
  module Relay
    module Agent
      module Job
        module_function

        # @param backend [Backend::Base]
        def run_backend(backend, dispatch_interval_s: 30, exec_interval_s: 2)
          work = Work.new
          work.add(Dispatch.new(backend, work, exec_interval_s: exec_interval_s), dispatch_interval_s)

          Puppet.notice(_('Starting backend %{backend} at interval %{interval} seconds' % {backend: backend.class.name, interval: dispatch_interval_s}))

          sched = Puppet::Scheduler::Scheduler.new
          sched.run_loop(work)
        end
      end
    end
  end
end
