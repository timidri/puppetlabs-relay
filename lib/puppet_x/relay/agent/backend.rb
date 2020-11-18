require 'puppet'

require_relative 'backend/base'
require_relative 'backend/bolt'
require_relative 'backend/dummy'
require_relative 'backend/orchestrator'
require_relative 'backend/ssh'
require_relative '../util/http'

module PuppetX
  module Relay
    module Agent
      module Backend
        FACTORIES = {
          bolt: proc do |relay_api, cfg|
            Bolt.new(relay_api,
                     bolt_command: cfg[:backend_bolt_command],
                     ssh_user: cfg[:backend_bolt_ssh_user],
                     ssh_password: cfg[:backend_bolt_ssh_password],
                     ssh_host_key_check: cfg[:backend_bolt_ssh_host_key_check])
          end,
          dummy: proc { |relay_api| Dummy.new(relay_api) },
          orchestrator: proc do |relay_api, cfg|
            orchestrator_api = Util::HTTP::PE.new(cfg[:backend_orchestrator_api_url], cfg[:backend_orchestrator_token])
            Orchestrator.new(relay_api, orchestrator_api)
          end,
          ssh: proc do |relay_api, cfg|
            SSH.new(relay_api, ssh_command: cfg[:backend_ssh_command])
          end,
        }.freeze

        module_function

        def new_for_configuration(name, relay_api, cfg)
          FACTORIES.fetch(name.to_sym).call(relay_api, cfg)
        end
      end
    end
  end
end
