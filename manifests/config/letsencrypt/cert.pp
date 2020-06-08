##
# Generate a letsencrypt certificate
define hx_website::config::letsencrypt::cert (
  Array $domains      = [$::fqdn],
  String $provider    = 'dns_cf'
) {

  $_domains = join($domains, ' -d ')

  if $provider == 'legacy' {

    exec {"generate-certificate-${domains[0]}":
      command => "/bin/certbot certonly --webroot --webroot-path /var/opt/apt/certs ${_domains}",
      creates => "/etc/letsencrypt/live/${domains[0]}/fullchain.pem"
    }

  } else {

    $hx_website::providers.each | $_provider | {
      if $_provider['name'] == $provider {
        $_auth = $_provider['options']
      }
    }

    exec {"generate-certificate-${domains[0]}":
      command     => "/var/opt/app/letsencrypt/acme/acme.sh --issue --dns ${provider} -d ${_domains} --home /var/opt/app/letsencrypt/.acme.sh",
      cwd         => '/var/opt/app/letsencrypt/acme',
      user        => 'letsencrypt',
      creates     => "/var/opt/app/letsencrypt/.acme.sh/${domains[0]}/${domains[0]}.cer",
      environment => $_auth
    }
  }

}
