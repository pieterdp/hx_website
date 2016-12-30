##
# Configure a website. This resource does the following:
# - create an Apache Virtual Host - the pp_apache class is requred as prerequisite for this resource.
# - if $hx_website::configure_redirect is true (default) and you're defining an SSL VHost, create a HTTP -> HTTPS redirect.
# - if $use_letsencrypt is true (default), (attempt) to get a Let's Encrypt certificate.
# - if $use_letsencrypt is false and you're defining an SSL VHost, use $key_loc and $cert_loc to copy the SSL certificate.
#
# Parameters
# $vhost_data: a hash of key-value pairs that can be pass directly to apache::vhost (required)
# $use_letsencrypt: attempt to get a Let's Encrypt certificate (default: true)
# $key_loc: location of the SSL key if it is an SSL host, but you're not using Let's Encrypt
# $cert_loc: location of the SSL certificate (see $key_loc)
##
define hx_website::website (
    $website_name = $title,
    $vhost_data = undef,
    $use_letsencrypt = true,
    $key_loc = undef,
    $cert_loc = undef,
) {
    validate_hash($vhost_data)

    if !defined(Class['hx_website']) {
        fail('You must include/define hx_website before using hx_website::website.')
    }

    hx_website::config::vhost {$website_name:
        vhost_data      => $vhost_data,
        use_letsencrypt => $use_letsencrypt,
        key_loc         => $key_loc,
        cert_loc        => $cert_loc
    }

}