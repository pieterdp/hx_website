##
# Parameter class
class hx_website::params {
    $configure_redirect = true
    $maintainer = "${::networking['hostname']}@${::networking['domain']}"
}