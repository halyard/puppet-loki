# @summary Configure Promtail client
#
# @param server sets the server address for Loki
class loki::client (
  String $server,
) {
  package { 'promtail': }

  -> file { '/etc/loki/promtail.yaml':
    ensure  => file,
    content => template('loki/promtail.yaml.erb'),
  }

  -> service { 'promtail':
    ensure => running,
    enable => true,
  }
}