# @summary Configure Loki instance
#
# @param log_hostname is the hostname for log submission
# @param web_hostname is the hostname for web UI access
# @param log_tls_account is the account details for requesting the log TLS cert
# @param web_tls_account is the account details for requesting the web TLS cert
# @param log_tls_challengealias is the domain to use for the log TLS cert validation
# @param web_tls_challengealias is the domain to use for the web TLS cert validation
class loki::server (
  String $log_hostname,
  String $web_hostname,
  String $log_tls_account,
  String $web_tls_account,
  Optional[String] $log_tls_challengealias = undef,
  Optional[String] $web_tls_challengealias = undef,
) {
  package { 'loki': }

  -> file { '/etc/loki/loki.yaml':
    ensure => file,
    contents => template('loki/loki.yaml.erb'),
  }

  -> file { ['/var/lib/loki', '/var/lib/loki/index', '/var/lib/loki/chunks']:
    ensure => directory,
  }

  -> service { 'loki':
    ensure => running,
    enable => true,
  }

  nginx::site { $log_hostname:
    proxy_target       => 'http://localhost:9095',
    tls_challengealias => $log_tls_challengealias,
    tls_account        => $log_tls_account,
  }

  nginx::site { $web_hostname:
    proxy_target       => 'http://localhost:3100'
    tls_challengealias => $web_tls_challengealias,
    tls_account        => $web_tls_account,
  }
}
