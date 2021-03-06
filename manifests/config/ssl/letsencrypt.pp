##
# Configure Let's Encrypt
# Warning! Here be dragons
class hx_website::config::ssl::letsencrypt () inherits hx_website {

  if $::os['family'] == 'Redhat' {

    package { 'epel-release':
      ensure => present
    }

    class { 'letsencrypt':
      email          => $hx_website::maintainer,
      require        => Package['epel-release'],
      configure_epel => false
    }

  } else {

    class { 'letsencrypt':
      email => $hx_website::maintainer,
    }

  }

  file { '/var/www/letsencrypt':
    ensure => directory,
  }

  file { '/var/www/letsencrypt/.well-known':
    ensure => directory,
  }

  file { '/var/www/letsencrypt/.well-known/acme-challenge':
    ensure => directory,
  }

  apache::custom_config { 'letsencrypt':
    content => 'Alias "/.well-known/acme-challenge" "/var/www/letsencrypt/.well-known/acme-challenge"
<Directory "/var/www/letsencrypt/.well-known/acme-challenge">
    Require all granted
</Directory>'
  }

}