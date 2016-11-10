##
# Configure the website resource
# Depends on pp_apache
class hx_website (
    $configure_redirect = $hx_website::params::configure_redirect,
    $maintainer = $hx_website::params::maintainer,
) inherits hx_website::params {

    if !defined(Class['pp_apache']) {
        fail('You must include/define pp_apache before using hx_website.')
    }
}