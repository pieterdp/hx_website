##
# Configure the website resource
# Depends on hx_apache
class hx_website (
  Boolean $configure_redirect  = false,
  String  $maintainer          = 'nobody@hx_website',
  Boolean $set_default_headers = false,
  Boolean $set_default_docroot = false,
  Array   $providers           = undef,
  String  $acme_version        = '2.8.5'
) {

  if !defined(Class['apache']) {
    fail('You need to configure the apache class before loading this module.')
  }

  include hx_website::config::letsencrypt::acme
}
