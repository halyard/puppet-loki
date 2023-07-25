# @summary Configure Loki instance
#
# @param hostname is the hostname for log submission
# @param grafana_password is the password for grafana to access logs
# @param promtail_password is the password for promtail to submit logs
# @param aws_access_key_id sets the AWS key to use for Route53 challenge
# @param aws_secret_access_key sets the AWS secret key to use for the Route53 challenge
# @param email sets the contact address for the certificate
# @param users sets extra users to allow for log access
# @param retention_enabled controls whether the server evicts old data
# @param retention_period sets how long to keep data before eviction
# @param backup_target sets the target repo for backups
# @param backup_watchdog sets the watchdog URL to confirm backups are working
# @param backup_password sets the encryption key for backup snapshots
# @param backup_environment sets the env vars to use for backups
# @param backup_rclone sets the config for an rclone backend
# @param backup_args sets extra parameters to pass to restic
class loki::server (
  String $hostname,
  String $grafana_password,
  String $promtail_password,
  String $aws_access_key_id,
  String $aws_secret_access_key,
  String $email,
  Hash[String, String] $users = {},
  Boolean $retention_enabled = false,
  String $retention_period = '91d',
  Optional[String] $backup_target = undef,
  Optional[String] $backup_watchdog = undef,
  Optional[String] $backup_password = undef,
  Optional[Hash[String, String]] $backup_environment = undef,
  Optional[String] $backup_rclone = undef,
  Optional[Array[String]] $backup_args = undef
) {
  package { ['loki', 'logcli']: }

  -> file { ['/var/lib/loki', '/var/lib/loki/index', '/var/lib/loki/chunks', '/var/lib/loki/wal']:
    ensure => directory,
    owner  => 'loki',
  }

  -> file { '/etc/systemd/system/loki.service':
    ensure => file,
    source => 'puppet:///modules/loki/loki.service',
  }

  -> file { '/etc/loki/loki.yaml':
    ensure  => file,
    content => template('loki/loki.yaml.erb'),
  }

  ~> service { 'loki':
    ensure => running,
    enable => true,
  }

  $merged_users = $users + {
    'grafana'  => $grafana_password,
    'promtail' => $promtail_password,
  }

  nginx::site { $hostname:
    proxy_target          => 'http://localhost:3100',
    aws_access_key_id     => $aws_access_key_id,
    aws_secret_access_key => $aws_secret_access_key,
    email                 => $email,
    users                 => $merged_users,
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
