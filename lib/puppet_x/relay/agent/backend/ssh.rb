require 'fileutils'
require 'shellwords'

require_relative 'process'

module PuppetX
  module Relay
    module Agent
      module Backend
        class SSH < Process
          # @param ssh_command [Array<String>]
          def initialize(relay_api, ssh_command: nil)
            super(relay_api)
            @ssh_command = ssh_command || ['ssh']
          end

          protected

          def format_commands(*)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
