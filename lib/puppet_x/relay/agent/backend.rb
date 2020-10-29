require 'puppet'

require_relative 'backend/base'
require_relative 'backend/dummy'
require_relative 'backend/orchestrator'
require_relative '../util/http'

module PuppetX
  module Relay
    module Agent
      module Backend
        FACTORIES = {
          dummy: proc { |relay_api| Dummy.new(relay_api) },
          orchestrator: proc do |relay_api, cfg|
            orchestrator_api = Util::HTTP::PE.new(
              cfg[:orchestrator_api_url] || "https://#{Puppet[:server]}:8143/orchestrator/v1/",
              cfg[:token],
            )
            Orchestrator.new(relay_api, orchestrator_api, run_interval_s: cfg[:run_interval_s] || 15)
          end,
        }.freeze

        module_function

        def new_for_configuration(name, relay_api, cfg)
          FACTORIES[name].call(relay_api, cfg)
        end
      end
    end
  end
end
