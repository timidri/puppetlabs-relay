require 'tempfile'

require 'puppet/application'
require 'puppet/daemon'

require_relative '../../puppet_x/relay/util/relay'
require_relative '../../puppet_x/relay/client'

class Puppet::Application::Relay < Puppet::Application

  include PuppetX::Relay::Util::Relay

  def summary
    _('Contact Relay SaaS')
  end

  # run_command is called to actually run the specified command
  def run_command
    # general todo list:
    # read the credentials from the yaml file
    # allow credentials passed in
    # allow different path arg
    # detect pe with is_function_available('pe_compiling_server_version'); does this matter?
    # contact the api for runs
    #
    # deploying runs
    # - pick a backend
    # - contact the orchesrator
    # - use ssh
    # - use bolt
    # endpoints:
    # - GET  /_puppet/runs
    #   prior to fork, get all runs
    # - POST /_puppet/runs/{runId}/accept
    #   post fork, accept specific run
    # - PUT  /_puppet/runs/{runId}/state
    #   post fork, update the run

    endpoint = "#{options[:relay_api_uri]}/_puppet/runs"

    Puppet.info(_('attempting to query the runs from') % { endpoint: endpoint })

    response = do_request(
      endpoint,
      'Get',
      nil,
      # TODO this isn't the right token, and needs an argument value
      access_token: @settings_hash['access_token'],
    )
    if response.code.to_i >= 300
      raise "Failed to contact the SaaS. Error from #{endpoint} (status: #{response.code}): #{response.body}"
    end

    Puppet.debug('successfully retrieved the runs')

    # TODO iterate over runs and fork with @runner here for poc, then refactor

    true
  end

  option('--debug')
  option('--evaltrace')
  option('--verbose')
  option('--daemonize')

  option('--relay-api-uri HOST')
  option('--bolt-path PATH')
  option('--node-puppet-path PATH')
  option('--openssh-client-path PATH')
  option('--parallelism NUMBER')

  option('--backend ARGUMENT') do |v|
    begin
      require_relative "../../puppet_x/relay/runner/#{arg.intern}"
    rescue LoadError
      raise _("Invalid backend %{arg}") % { arg: arg }
    end
    options[:backend] = arg.intern
  end

  def handle_unknown(opt, arg)
    # last chance to manage an option
    # let's say to the framework we finally handle this option
    true
  end

  def preinit
    # Set up the default values
    {
      :debug => false,
      :evaltrace => false,
      :verbose => false,
      :daemonize => false,

      :bolt_path => 'bolt',
      :relay_api_uri => 'https://api.relay.sh',
      :node_puppet_path => 'puppet',
      :openssh_client_path => 'ssh',
      :parallelism => 1,
      :backend => 'dummy',
    }.each do |opt,val|
      options[opt] = val
    end
  end

  def setup
    super
    setup_client
  end

  def read
    # read action
  end

  def write
    # writeaction
  end

  private

  def setup_client
    @settings_hash = settings
  end

  def get_runner(hostname)
    runner = PuppetX::Relay::Runner.get(options[:backend]).new(hostname)
  end

  def daemonize_process(runner)
    pidfile = Tempfile.new(hostname)

    daemon = Puppet::Daemon.new(runner, Puppet::Util::Pidlock.new(pidfile))
    daemon.daemonize
    daemon
  end
end
