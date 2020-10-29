require 'puppet'

require_relative '../../agent/model'
require_relative 'client'

module PuppetX
  module Relay
    module Util
      module HTTP
        class RelayAPI < Client
          def initialize(base_url, token)
            super(base_url)
            @token = token
          end

          # @return [Array<Agent::Model::Run>]
          def get_runs
            resp = get('_puppet/runs')
            # FIXME: Handle errors!
            data = JSON.parse(resp.body)
            data['runs'].map { |run| Agent::Model::Run.from_h(run) }
          end

          # @param run [Agent::Model::Run]
          def put_run_state(run)
            Puppet.debug(_('Updating run %{id} state to %{state}' % {id: run.id, state: run.state.inspect}))
            put("_puppet/runs/#{run.id}/state", body: run.state)
          end

          # @param run [Agent::Model::Run]
          def post_accept_run(run)
            resp = post("_puppet/runs/#{run.id}/accept")
            resp.instance_of? Net::HTTPAccepted
          end

          protected

          def update_request!(request)
            request['Authorization'] = "Bearer #{@token}"
          end
        end
      end
    end
  end
end
