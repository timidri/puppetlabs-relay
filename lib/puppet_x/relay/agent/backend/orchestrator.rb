require 'json'

require 'puppet'
require 'puppet/scheduler'

require_relative '../../util/http'
require_relative '../model'
require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Backend
        class Orchestrator < Base
          # @param orchestrator_api [Util::HTTP::Client]
          # @param run_interval_s [Integer]
          def initialize(relay_api, orchestrator_api, run_interval_s: 15)
            super(relay_api)
            @orchestrator_api = orchestrator_api
            @run_interval_s = run_interval_s
          end

          def exec(run)
            # Start deployment.
            run = deploy(run)

            # Delegate work.
            job = Puppet::Scheduler.create_job(@run_interval_s) do |j|
              _resp = @relay_api.put_run_state(run)
              # XXX: FIXME: Handle errors here!

              case run.state.status
              when :complete
                j.disable
              else
                run = check_complete(j, run)
              end
            end

            # Start a scheduler for this work.
            sched = Puppet::Scheduler::Scheduler.new
            sched.run_loop([job])

            run
          end

          private

          # @param run [Model::Run]
          def deploy(run)
            new_state =
              case run.state.status
              when :pending
                resp = @orchestrator_api.post(
                  'command/deploy',
                  body: {
                    environment: run.environment,
                    scope: run.scope,
                    noop: run.noop,
                    debug: run.debug,
                    trace: run.trace,
                    evaltrace: run.evaltrace,
                  },
                )
                # XXX: FIXME: Handle errors here!

                data = JSON.parse(resp.body)

                Puppet.info(_('Orchestrator job %{job_id} started for run %{id}' % {job_id: data['job']['id'], id: run.id}))
                run.state.to_in_progress(next_update_before, job_id: data['job']['id'])
              else
                run.state.to_in_progress(next_update_before)
              end

            run.with_state(new_state)
          end

          # @param job [Puppet::Scheduler::Job]
          # @param run [Model::Run]
          def check_complete(job, run)
            resp = @orchestrator_api.get(run.state.job_id)
            # XXX: FIXME: Handle errors here!

            data = JSON.parse(resp.body)

            new_state =
              case data['state']
              when 'finished', 'failed'
                run.state.to_complete(outcome: data['state'])
              else
                run.state.to_in_progress(next_update_before(job.last_run))
              end

            run.with_state(new_state)
          end

          # @return [Time]
          def next_update_before(t = Time.now)
            t + @run_interval_s * 3
          end
        end
      end
    end
  end
end
