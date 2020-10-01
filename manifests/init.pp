# @summary
#   This class contains the common setup code for relay::reporting
#
# @api private
class relay (
  String[1] $access_token,
  Optional[String[1]] $reports_url = 'https://api.relay.sh/api/events',
) {
  # If the report processor changed between module versions then we need to restart puppetserver.
  # To detect when the report processor changed, we compare its current version with the version
  # stored in the settings file. This is handled by the 'check_report_processor' custom function.
  #
  # Note that the $report_processor_changed variable is necessary to avoid restarting pe-puppetserver
  # everytime the settings file changes due to non-report processor reasons (like e.g. if the relay
  # token changes). We also return the current report processor version so that we can persist it
  # in the settings file.
  #
  # The confdir defaults to /etc/puppetlabs/puppet on *nix systems
  # https://puppet.com/docs/puppet/5.5/configuration.html#confdir
  $settings_file_path = "${settings::confdir}/relay_reporting.yaml"
  [$report_processor_changed, $report_processor_version] = relay::check_report_processor($settings_file_path)
  if $report_processor_changed {
    # Restart puppetserver to pick-up the changes
    $settings_file_notify = [Service['pe-puppetserver']]
  } else {
    $settings_file_notify = []
  }
  file { $settings_file_path:
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0640',
    content => epp('relay/relay_reporting.yaml.epp', {
      access_token             => $access_token,
      reports_url              => $reports_url,
      report_processor_version => $report_processor_version,
      }),
    notify  => $settings_file_notify,
  }

  # Update the reports setting in puppet.conf
  ini_subsetting { 'puppetserver puppetconf add relay report processor':
    ensure               => present,
    path                 => $settings::config,
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'relay',
    subsetting_separator => ',',
    # Note that Puppet refreshes resources only once so multiple notifies
    # in a single run are safe. In our case, this means that if the settings
    # file resource and the ini_subsetting resource both notify pe-puppetserver,
    # then pe-puppetserver will be refreshed (restarted) only once.
    notify               => Service['pe-puppetserver'],
    require              => File[$settings_file_path],
  }
}
