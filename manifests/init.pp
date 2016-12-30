##
# Configure the website resource
# Depends on pp_apache
class hx_website (
    $configure_redirect = $hx_website::params::configure_redirect,
    $maintainer = $hx_website::params::maintainer,
) inherits hx_website::params {

    include pp_apache
}