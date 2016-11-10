##
# Parameter class
class hx_website::params {
    $configure_redirect = false
    $maintainer = "${::networking['hostname']}@${::networking['domain']}"
}