##
# Configure the website resource
# Depends on hx_apache
class hx_website (
    Boolean $configure_redirect  = false,
    String  $maintainer          = 'nobody@hx_website',
    Boolean $set_default_headers = false,
    Boolean $set_default_docroot = false,
) {

    if ! defined(Class['apache']) {
        fail('You need to configure the apache class before loading this module.')
    }
}