# @api private
class relay::service {
  $agent_service_ensure = $relay::install::agent_enabled ? {
    true    => running,
    default => stopped,
  }

  service { 'relay-agent':
    ensure    => $agent_service_ensure,
    enable    => $relay::install::agent_enabled,
    subscribe => File[$relay::settings_file],
  }
}
