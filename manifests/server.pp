# @summary Configure Loki instance
#
# @param hostname is the hostname for log submission
# @param tls_account is the account details for requesting the TLS cert
# @param grafana_password is the password for grafana to access logs
# @param promtail_password is the password for promtail to submit logs
# @param tls_challengealias is the domain to use for TLS cert validation
# @param backup_target sets the target repo for backups
# @param backup_watchdog sets the watchdog URL to confirm backups are working
# @param backup_password sets the encryption key for backup snapshots
# @param backup_environment sets the env vars to use for backups
# @param backup_rclone sets the config for an rclone backend
# @param backup_args sets extra parameters to pass to restic
class loki::server (
  String $hostname,
  String $tls_account,
  String $grafana_password,
  String $promtail_password,
  Optional[String] $tls_challengealias = undef,
  Optional[String] $backup_target = undef,
  Optional[String] $backup_watchdog = undef,
  Optional[String] $backup_password = undef,
  Optional[Hash[String, String]] $backup_environment = undef,
  Optional[String] $backup_rclone = undef,
  Optional[Array[String]] $backup_args = undef
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

  if $backup_target != '' {
    backup::repo { 'loki':
      source        => '/var/lib/loki',
      target        => $backup_target,
      watchdog_url  => $backup_watchdog,
      password      => $backup_password,
      environment   => $backup_environment,
      rclone_config => $backup_rclone,
      args          => $backup_args,
    }
  }
}
