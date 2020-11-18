require 'puppet'

require_relative '../../agent/model'
require_relative 'client'

# rubocop:disable Style/AccessorMethodName

module PuppetX
  module Relay
    module Util
      module HTTP
        class RelayAPI < Client
          class MissingTokenError < StandardError; end

          def initialize(base_url, token)
            super(base_url)
            @token = token

            raise MissingTokenError unless @token
          end

          # @return [Array<Agent::Model::Run>]
          def get_runs
            resp = get('_puppet/runs')
            resp.value

            data = JSON.parse(resp.body)
            data['runs'].map { |run| Agent::Model::Run.from_h(run) }
          end

          # @param run [Agent::Model::Run]
          # @return [Agent::Model::Run]
          def put_run_state(run)
            Puppet.debug(_('Updating run %{id} state to %{state}') % { id: run.id, state: run.state.inspect })
            resp = put("_puppet/runs/#{run.id}/state", body: run.state)
            resp.value

            # FIXME: Un-stub this!
            #data = JSON.parse(resp.body)
            data = run.state.to_h
            data['updated_at'] = Time.now.iso8601
            run.with_state(Agent::Model::State.from_h(data))
          end

          # @param run [Agent::Model::Run]
          def post_accept_run(run)
            resp = post("_puppet/runs/#{run.id}/accept")
            resp.instance_of? Net::HTTPAccepted
          end

          # @param data [Hash]
          def emit_event(data)
            resp = post('api/events', body: { 'data' => data })
            resp.value
            resp
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
