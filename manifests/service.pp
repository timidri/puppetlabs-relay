# @api private
class relay::service {
  $agent_service_ensure = $relay::relay_connection_token ? {
    undef   => stopped,
    default => running,
  }

  service { 'relay-agent':
    ensure    => $agent_service_ensure,
    subscribe => File[$relay::settings_file],
  }
}
