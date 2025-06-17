# @summary Configure Promtail client
#
# @param server sets the server address for Loki
# @param password sets the promtail user password to submit logs
# @param logpaths sets additional directories to pull logs from
# @param syslog_sources sets IPs to expect syslog data from
# @param journald_retention sets how long to retain local journal data
class loki::client (
  String $server,
  String $password,
  Hash[String, String] $logpaths = {},
  Array[String] $syslog_sources = [],
  String $journald_retention = '0',
) {
  include loki

  package { 'promtail': }

  -> file { '/etc/loki':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  -> file { '/etc/loki/promtail.yaml':
    ensure  => file,
    content => template('loki/promtail.yaml.erb'),
  }

  ~> service { 'promtail':
    ensure => running,
    enable => true,
  }

  file { '/etc/systemd/system/promtail.service.d':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file { '/etc/systemd/system/promtail.service.d/override.conf':
    ensure => file,
    source => 'puppet:///modules/loki/override.conf',
  }

  file { '/etc/systemd/journald.conf.d':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file { '/etc/systemd/journald.conf.d/rotate.conf':
    ensure  => file,
    content => template('loki/rotate.conf.erb'),
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
