require 'fileutils'
require 'shellwords'

require 'puppet'

require_relative 'process'

module PuppetX
  module Relay
    module Agent
      module Backend
        class Bolt < Process
          # @param bolt_command [Array<String>]
          def initialize(relay_api,
                         bolt_command: nil,
                         ssh_user: nil,
                         ssh_password: nil,
                         ssh_host_key_check: nil)
            super(relay_api)
            @bolt_command = bolt_command || ['bolt']
            @ssh_user = ssh_user || 'root'
            @ssh_password = ssh_password
            @ssh_host_key_check = ssh_host_key_check.nil? ? true : ssh_host_key_check
          end

          protected

          def format_commands(run, state_dir)
            raise NotImplementedError unless run.is_a?(Model::Run)
            raise NotImplementedError unless run.scope.is_a?(Model::Scope::Nodes)

            # Need a temporary Boltdir for some users that don't have a proper
            # $HOME.
            boltdir = File.join(state_dir, 'Boltdir')
            Puppet::FileSystem.mkpath(boltdir)

            agent_command = [
              'puppet',
              'agent',
              '--no-daemonize',
              '--onetime',
            ]
            agent_command << '--environment' << run.environment
            agent_command << '--noop' if run.noop
            agent_command << '--debug' if run.debug
            agent_command << '--trace' if run.trace
            agent_command << '--evaltrace' if run.evaltrace

            command = @bolt_command
            command += [
              'command',
              'run',
              agent_command.shelljoin,
              '--boltdir',
              boltdir,
              '--targets',
              run.scope.value.join(',').shellescape,
              '--no-save-rerun',
              '--no-tty',
            ]
            command << '--user' << @ssh_user
            command << '--password' << @ssh_password if @ssh_password
            command << '--no-host-key-check' unless @ssh_host_key_check

            [command]
          end
        end
      end
    end
  end
end
