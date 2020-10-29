require 'tempfile'

require 'puppet/application'
require 'puppet/daemon'

require_relative '../../puppet_x/relay'

class Puppet::Application::Relay < Puppet::Application

  include PuppetX::Relay::Util::Relay

  def summary
    _('The daemon to support Relay by Puppet')
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
  [--backend <BACKEND>]
  [--backend-config <KEY1>=<VALUE1>[,<KEY2>=<VALUE2>[,...]]]

OPTIONS
-------

* --help:
  Print this help message.
    HELP
  end

  def main
    PuppetX::Relay::Agent::Job.run_backend(@backend)
    true
  end

  option('--test', '-t')
  option('--debug', '-d')
  option('--verbose', '-v')
  option('--daemonize')

  option('--relay-api-url URL') { |opt| options[:relay_api_url] = opt }
  option('--relay-api-token TOKEN') { |opt| options[:relay_api_token] = opt }

  option('--backend BACKEND', '-b', PuppetX::Relay::Agent::Backend::FACTORIES.keys)
  option('--backend-config KEY1=VALUE1,KEY2=VALUE2', Array) do |opt|
    opt
      .select { |pair| !pair.nil? }
      .each do |pair|
        key, value = pair.split('=', 2)
        options[:backend_config][key.intern] = value.nil? ? true : value
      end
  end

  def preinit
    # Set up the default values
    {
      :test => false,
      :debug => false,
      :verbose => false,
      :daemonize => true,
      :relay_api_url => 'https://api.relay.sh',
      :backend => 'dummy',
      :backend_config => {},
    }.each { |opt, val| options[opt] = val }
  end

  def setup
    options[:verbose] = true if options[:test]
    options[:daemonize] = false if options[:test]

    super

    api = PuppetX::Relay::Util::HTTP::RelayAPI.new(options[:relay_api_url], options[:relay_api_token])
    @backend = PuppetX::Relay::Agent::Backend.new_for_configuration(options[:backend], api, options[:backend_config])
  end
end
