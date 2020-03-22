##
# Generate a letsencrypt certificate
define hx_website::config::letsencrypt::cert (
  Array $domains   = [$::fqdn],
  String $provider = 'dns_cf'
) {

  $_domains = join($domains, ' -d ')

  exec {"generate-certificate-${domains[0]}":
    command => "/bin/bash -c 'source /var/opt/app/letsencrypt/.providers/.${provider} && /var/opt/app/letsencrypt/acme/acme.sh --issue --dns ${provider} -d ${_domains}'",
    cwd     => '/var/opt/app/letsencrypt/acme',
    user    => 'letsencrypt',
    creates => "/var/opt/app/letsencrypt/.acme.sh/${domains[0]}/${domains[0]}.cer"
  }

}
