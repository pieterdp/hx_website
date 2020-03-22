##
# Configure a VirtualHost
define hx_website::config::vhost (
  $website_name    = $title,
  $vhost_data      = undef,
  $use_letsencrypt = true,
  $cert_loc        = undef,
  $key_loc         = undef,
  $provider        = 'dns_cf'
) {

  validate_hash($vhost_data)

  if !defined(Class['hx_website']) {
    fail('You must include/define hx_website before using hx_website::config::vhost.')
  }

  if ($vhost_data['port'] == 443) {
    if ($use_letsencrypt == true) {

      include hx_website::config::letsencrypt::acme

      $domains = [$vhost_data['servername']]

      if has_key($vhost_data, 'serveraliases') {
        $lets_domains = concat($domains, $vhost_data['serveraliases'])
      } else {
        $lets_domains = $domains
      }

      hx_website::config::letsencrypt::cert {$lets_domains[0]:
        domains  => $lets_domains,
        provider => $provider
      }

      file { $vhost_data['ssl_cert']:
        ensure  => present,
        links   => follow,
        source  => "file:///var/opt/app/letsencrypt/.acme.sh/${vhost_data['servername']}/fullchain.cer",
        owner   => root,
        group   => root,
        mode    => '0644',
        before  => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
        require => Letsencrypt::Certonly[$vhost_data['servername']],
        notify  => Class['Apache::Service'],
      }
      file { $vhost_data['ssl_key']:
        ensure  => present,
        links   => follow,
        source  => "file:///var/opt/app/letsencrypt/.acme.sh/${vhost_data['servername']}/${vhost_data['servername']}.key",
        owner   => root,
        group   => root,
        mode    => '0640',
        before  => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
        require => Letsencrypt::Certonly[$vhost_data['servername']],
        notify  => Class['Apache::Service'],
      }
    } else {
      if $cert_loc == undef {
        fail('If you define an SSL host and set use_letsencrypt to false, you must provide $cert_loc and $key_loc.')
      }
      if $key_loc == undef {
        fail('If you define an SSL host and set use_letsencrypt to false, you must provide $cert_loc and $key_loc.')
      }

      file { $vhost_data['ssl_cert']:
        ensure => present,
        source => $cert_loc,
        owner  => root,
        group  => root,
        mode   => '0644',
        before => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
        notify => Class['Apache::Service'],
      }
      file { $vhost_data['ssl_key']:
        ensure => present,
        source => $key_loc,
        owner  => root,
        group  => root,
        mode   => '0640',
        before => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
        notify => Class['Apache::Service'],
      }
    }

    if $hx_website::configure_redirect == true {
      ##
      # Configure an additional VHost that redirects all
      # unencrypted traffic to the encrypted host.
      if !has_key($vhost_data, 'serveraliases') {
        $serveraliases = []
      } else {
        $serveraliases = $vhost_data['serveraliases']
      }

      apache::vhost { "${vhost_data['servername']}_80":
        servername      => $vhost_data['servername'],
        port            => 80,
        docroot         => $vhost_data['docroot'],
        docroot_owner   => $vhost_data['docroot_owner'],
        docroot_group   => $vhost_data['docroot_group'],
        serveraliases   => $serveraliases,
        redirect_status => 'permanent',
        redirect_dest   => "https://${vhost_data['servername']}/"
      }
    }
  }

  # Docroot
  $docroot = {
    path           => $vhost_data['docroot'],
    options        => [
      'Indexes',
      'FollowSymLinks',
    ],
    allow_override => [
      'All'
    ]
  }
  if $hx_website::set_default_docroot == true {
    if !has_key($vhost_data, 'directories') {
      $directories = [$docroot]
    } else {
      $directories = $vhost_data['directories'] + [$docroot]
    }
  } else {
    $directories = $vhost_data['directories']
  }

  # Headers
  if $hx_website::set_default_headers == true {
    $http_headers = [
      'always set Referrer-Policy "strict-origin-when-cross-origin"',
    ]

    if $vhost_data['port'] == 443 {
      $template_headers = $http_headers + [
        'always set Strict-Transport-Security "max-age=63072000;includeSubdomains;"',
      ]
    } else {
      $template_headers = $http_headers
    }

    if has_key($vhost_data, 'headers') {
      $headers = $template_headers + $vhost_data['headers']
    } else {
      $headers = $template_headers
    }
  } else {
    $headers = $vhost_data['headers']
  }

  $vhost = $vhost_data + {
    directories => $directories,
    headers     => unique($headers),
  }

  apache::vhost { "${vhost_data['servername']}_${vhost_data['port']}":
    * => $vhost,
  }

}
