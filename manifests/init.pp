# @summary Set up system for loki/promtail
class loki (
) {
  if $facts['os']['family'] =~ /(Debian|Ubuntu)/ {
    apt::key { 'loki':
      id      => '0E22EB88E39E12277A7760AE9E439B102CF3C0C6',
      source  => 'https://apt.grafana.com/gpg-full.key',
      server  => 'keyserver.ubuntu.com',
      options => '',
    }

    -> apt::source { 'loki':
      location => 'https://apt.grafana.com',
      release  => 'stable',
      repos    => 'main',
    }
  }
}
