# @summary Configure Loki instance
#
# @param hostname is the hostname for log submission
# @param tls_account is the account details for requesting the TLS cert
# @param tls_challengealias is the domain to use for TLS cert validation
class loki::server (
  String $hostname,
  String $tls_account,
  Optional[String] $tls_challengealias = undef,
) {
  package { 'loki': }

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
  }
}
