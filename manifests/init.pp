##
# Configure the website resource
# Depends on hx_apache
class hx_website (
  Boolean $configure_redirect  = false,
  String  $maintainer          = 'nobody@hx_website',
  Boolean $set_default_headers = false,
  Boolean $set_default_docroot = false,
  Array   $providers           = undef,
  String  $acme_version        = '2.8.5',
  Boolean $legacy_support      = false
) {

  if !defined(Class['apache']) {
    fail('You need to configure the apache class before loading this module.')
  }

  if $legacy_support {
    package {'certbot':
      ensure => installed
    }

    cron {'certbot-renew':
      command => '/bin/certbot renew -q',
      user    => root,
      hour    => 1,
      minute  => 0
    }
  }
}
