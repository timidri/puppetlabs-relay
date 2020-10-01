# TODO: Properly document this class
class relay::reporting (
  String[1] $access_token,
  Optional[String[1]] $reports_url = undef,
) {
  class { 'relay':
    access_token => $access_token,
    reports_url  => $reports_url,
  }
}
