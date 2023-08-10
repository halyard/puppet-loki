# @summary Set up system for loki/promtail
class loki (
) {
  if $facts['os']['family'] =~ /(Debian|Ubuntu)/ {
    apt::source { 'loki':
      location => 'https://apt.grafana.com',
      repos    => 'stable main',
      key      => {
        'id'     => '0E22EB88E39E12277A7760AE9E439B102CF3C0C6',
        'server' => 'pgp.mit.edu',
      },
    }
  }
}
