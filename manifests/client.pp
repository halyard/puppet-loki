# @summary Configure Promtail client
#
# @param server sets the server address for Loki
# @param password sets the promtail user password to submit logs
# @param logpaths sets additional directories to pull logs from
# @param syslog_sources sets IPs to expect syslog data from
class loki::client (
  String $server,
  String $password,
  Hash[String, String] $logpaths = {},
  Array[String] $syslog_sources = [],
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

  if $syslog_sources.length > 0 {
    $syslog_sources.each |String $source| {
      firewall { "100 allow syslog udp input from ${source}":
        dport  => 514,
        source => $source,
        proto  => 'udp',
        action => 'accept',
      }
    }

    package { 'syslog-ng': }

    -> file { '/etc/syslog-ng/syslog-ng.conf':
      ensure => file,
      source => 'puppet:///modules/loki/syslog-ng.conf',
    }

    ~> service { 'syslog-ng@default':
      ensure => running,
      enable => true,
    }
  }
}
