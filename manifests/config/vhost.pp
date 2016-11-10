##
# Configure a VirtualHost
define hx_website::config::vhost (
    $website_name = $title,
    $vhost_data = undef,
    $use_letsencrypt = false,
    $cert_loc = undef,
    $key_loc = undef,
    $ca_loc = undef,
    ) {

    validate_hash($vhost_data)

    if !defined(Class['hx_website']) {
        fail('You must include/define hx_website before using hx_website::config::vhost.')
    }

    if $vhost_data['port'] == 443 and $use_letsencrypt == true {

        $domains = [$vhost_data['servername']]

        if has_key($vhost_data, 'serveraliases') {
            $lets_domains = concat($domains, $vhost_data['serveraliases'])
        } else {
            $lets_domains = $domains
        }

        letsencrypt::certonly {$vhost_data['servername']:
            domains       => $lets_domains,
            plugin        => 'webroot',
            webroot_paths => ['/var/letsencrypt'],
            manage_cron   => true,
        }

        file {$vhost_data['ssl_cert']:
            ensure  => present,
            links   => follow,
            source  => "file:///etc/letsencrypt/live/${vhost_data['servername']}/fullchain.pem",
            owner   => root,
            group   => root,
            mode    => '0644',
            before  => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
            require => Letsencrypt::Certonly[$vhost_data['servername']],
        }
        file {$vhost_data['ssl_key']:
            ensure  => present,
            links   => follow,
            source  => "file:///etc/letsencrypt/live/${vhost_data['servername']}/privkey.pem",
            owner   => root,
            group   => ssl-cert,
            mode    => '0640',
            before  => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
            require => Letsencrypt::Certonly[$vhost_data['servername']],
        }

        # Let's Encrypt root
        file {'/etc/ssl/certs/lets-encrypt-x3-cross-signed.pem':
            ensure => present,
            source => 'https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem',
            owner  => root,
            group  => ssl-cert,
            mode   => '0644',
            before => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
        }
    }

    if $vhost_data['port'] == 443 and $use_letsencrypt == false {

        if $cert_loc == undef {
            fail('If you define an SSL host and set use_letsencrypt to false, you must provide $cert_loc and $key_loc.')
        }
        if $key_loc == undef {
            fail('If you define an SSL host and set use_letsencrypt to false, you must provide $cert_loc and $key_loc.')
        }

        file {$vhost_data['ssl_cert']:
            ensure => present,
            source => $cert_loc,
            owner  => root,
            group  => root,
            mode   => '0644',
            before => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
        }
        file {$vhost_data['ssl_key']:
            ensure => present,
            source => $key_loc,
            owner  => root,
            group  => ssl-cert,
            mode   => '0640',
            before => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
        }
        if $ca_loc != undef and has_key($vhost_data, 'ssl_ca') {
            file {$vhost_data['ssl_ca']:
                ensure => present,
                source => $ca_loc,
                owner  => root,
                group  => ssl-cert,
                mode   => '0644',
                before => Apache::Vhost["${vhost_data['servername']}_${vhost_data['port']}"],
            }
        }
    }

    apache::vhost {"${vhost_data['servername']}_${vhost_data['port']}":
        * => $vhost_data,
    }

    if $hx_website::configure_redirect == true and $vhost_data['port'] == 443 {
        ##
        # Configure an additional VHost that redirects all
        # unencrypted traffic to the encrypted host.
        if ! has_key($vhost_data, 'serveraliases') {
            $serveraliases = []
        } else {
            $serveraliases = $vhost_data['serveraliases']
        }

        apache::vhost {"${vhost_data['servername']}_80":
            servername      => $vhost_data['servername'],
            port            => 80,
            docroot         => $vhost_data['docroot'],
            serveraliases   => $::serveraliases,
            redirect_status => 'permanent',
            redirect_dest   => "https://${vhost_data['servername']}/"
        }
    }

}