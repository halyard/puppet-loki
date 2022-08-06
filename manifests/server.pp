# @summary Configure Loki instance
#
# @param hostname is the hostname for log submission
# @param tls_account is the account details for requesting the TLS cert
# @param grafana_password is the password for grafana to access logs
# @param promtail_password is the password for promtail to submit logs
# @param tls_challengealias is the domain to use for TLS cert validation
class loki::server (
  String $hostname,
  String $tls_account,
  String $grafana_password,
  String $promtail_password,
  Optional[String] $tls_challengealias = undef,
) {
  package { ['loki', 'logcli']: }

  -> file { '/etc/loki/loki.yaml':
    ensure  => file,
    content => template('loki/loki.yaml.erb'),
  }

  -> file { ['/var/lib/loki', '/var/lib/loki/index', '/var/lib/loki/chunks', '/var/lib/loki/wal']:
    ensure => directory,
    owner  => 'loki',
  }

  -> service { 'loki':
    ensure => running,
    enable => true,
  }

  nginx::site { $hostname:
    proxy_target       => 'http://localhost:3100',
    tls_challengealias => $tls_challengealias,
    tls_account        => $tls_account,
    users              => {
      'grafana'  => $grafana_password,
      'promtail' => $promtail_password,
    },
  }
}
