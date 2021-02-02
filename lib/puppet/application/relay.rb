require 'puppet'
require 'puppet/application'
require 'puppet/daemon'
require 'puppet/scheduler'
require 'puppet/util/pidlock'

require_relative '../../puppet_x/relay'

# This class extends puppet CLI framework to add
# a `puppet relay` subcommand for the relay agent.
class Puppet::Application::Relay < Puppet::Application
  def summary
    _('The agent for Relay by Puppet')
  end

  def help
    <<-HELP
puppet-relay(8) -- #{summary}
========

SYNOPSIS
--------
Runs a daemon process that polls Relay and starts Puppet agent runs when
requested.

USAGE
-----
puppet relay [-h|--help] [-t|--test] [--daemonize|--no-daemonize]
  [-d|--debug] [-v|--verbose] [--config <FILE>]
  [-b|--backend <BACKEND>]
  [--backend-config <KEY1>=<VALUE1>[,<KEY2>=<VALUE2>[,...]]]

OPTIONS
-------

* --help:
  Print this help message.
    HELP
  end

  def main
    with_daemon do
      work = PuppetX::Relay::Agent::Job::Work.new
      dispatch = PuppetX::Relay::Agent::Job::Dispatch.new(@ctx.backend, work, @ctx.settings[:state_dir])

      if Puppet[:onetime]
        Puppet.notice(_('Running backend %{backend}') % { backend: @ctx.backend.class.name })
        work.add(PuppetX::Relay::Agent::Job::Once.new(dispatch))
      else
        Puppet.notice(_('Starting loop for backend %{backend} every 30 seconds') % { backend: @ctx.backend.class.name })
        work.add(dispatch, 30)
      end

      sched = Puppet::Scheduler::Scheduler.new
      sched.run_loop(work)
    end
  end

  option('--config FILE')

  option('--test', '-t')
  option('--debug', '-d')
  option('--verbose', '-v')

  option('--backend BACKEND', '-b', PuppetX::Relay::Agent::Backend::FACTORIES.keys)
  option('--backend-config KEY1=VALUE1,KEY2=VALUE2', Array) do |opt|
    @backend_options ||= {}

    opt
      .reject { |pair| pair.nil? }
      .each do |pair|
        key, value = pair.split('=', 2)
        @backend_options[key] = value.nil? ? true : value
      end
  end

  def setup
    if options[:test]
      Puppet[:daemonize] = false
      Puppet[:onetime] = true
      options[:verbose] = true
    end

    super

    cfg = PuppetX::Relay::Util::DefaultSettings.new
    cfg = PuppetX::Relay::Util::FileSettings.new(cfg, file: options.delete(:config))
    cfg = PuppetX::Relay::Util::OverlaySettings.new(cfg, options)
    cfg = PuppetX::Relay::Util::BackendOverlaySettings.new(cfg, @backend_options || {})
    @ctx = PuppetX::Relay::Agent::Context.new(cfg)
  end

  private

  def with_daemon
    return unless block_given?

    lock = Puppet::Util::Pidlock.new(File.join(@ctx.settings[:state_dir], 'agent.pid'))
    begin
      if Puppet[:daemonize]
        Process.daemon
        raise "Could not create PID file: #{lock.file_path}" unless lock.lock
        Puppet::Util::Log.close(:console)
        Puppet::Daemon.close_streams
      end

      yield
    ensure
      lock.unlock
    end
  end
end
