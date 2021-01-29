require 'json'

require_relative '../../util/http'
require_relative '../model'
require_relative '../job/schedule'
require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Backend
        class Orchestrator < Base
          # @param orchestrator_api [Util::HTTP::Client]
          def initialize(relay_api, orchestrator_api)
            super(relay_api)
            @orchestrator_api = orchestrator_api
          end

          def exec(run, _state_dir, schedule)
            case run.state.status
            when :pending
              deploy(run, schedule)
            else
              check_complete(run, schedule)
            end
          end

          private

          # @param run [Model::Run]
          # @param schedule [Job::Schedule]
          def deploy(run, schedule)
            payload = {
                environment: run.environment,
                scope: run.scope,
                debug: run.debug,
                trace: run.trace,
                evaltrace: run.evaltrace,
            }
            run.noop ? payload[:noop] = true : payload[:no_noop] = true
            resp = @orchestrator_api.post(
              'command/deploy',
              body: payload,
            )
            resp.value

            data = JSON.parse(resp.body)

            Puppet.info(_('Orchestrator job %{job_id} started for run %{id}') % { job_id: data['job']['name'], id: run.id })

            new_state = run.state.to_in_progress(schedule.next_update_before, job_id: data['job']['name'])
            run.with_state(new_state)
          end

          # @param run [Model::Run]
          # @param schedule [Job::Schedule]
          def check_complete(run, schedule)
            resp = @orchestrator_api.get("jobs/#{run.state.job_id}")
            resp.value

            data = JSON.parse(resp.body)

            new_state =
              case data['state']
              when 'finished', 'failed'
                run.state.to_complete(outcome: data['state'])
              else
                run.state.to_in_progress(schedule.next_update_before)
              end

            run.with_state(new_state)
          end
        end
      end
    end
  end
end
