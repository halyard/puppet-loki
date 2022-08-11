# @summary Configure Promtail client
#
# @param server sets the server address for Loki
# @param password sets the promtail user password to submit logs
# @param logpaths sets additional directories to pull logs from
class loki::client (
  String $server,
  String $password,
  Hash[String, String] $logpaths = {},
) {
  package { 'promtail': }

  -> file { '/etc/loki/promtail.yaml':
    ensure  => file,
    content => template('loki/promtail.yaml.erb'),
  }

  ~> service { 'promtail':
    ensure => running,
    enable => true,
  }
}
