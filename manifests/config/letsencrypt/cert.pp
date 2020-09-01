##
# Generate a letsencrypt certificate
define hx_website::config::letsencrypt::cert (
  Array $domains      = [$::fqdn],
  String $provider    = 'dns_cf'
) {

  $_domains = join($domains, ' -d ')

  if $provider == 'legacy' {

    if $::os['family'] == 'Debian' {
      $_certbot_path = '/usr/bin/certbot'
    } else {
      $_certbot_path = '/bin/certbot'
    }

    exec {"generate-certificate-${domains[0]}":
      command => "${_certbot_path} certonly --webroot --webroot-path /var/opt/app/certs -d ${_domains}",
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
      creates     => "/var/opt/app/letsencrypt/acme/${domains[0]}/${domains[0]}.cer",
      environment => $_auth
    }
  }

}
