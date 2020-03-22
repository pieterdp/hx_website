# Configure DNS-based certificate issuance with acme.sh
class hx_website::config::letsencrypt::acme {

  user {'letsencrypt':
    ensure     => present,
    managehome => true,
    home       => '/var/opt/app/letsencrypt',
    system     => true
  }

  file {'/var/opt/app/letsencrypt/acme':
    ensure => directory,
    owner  => 'letsencrypt',
    group  => 'letsencrypt'
  }

  file {'/var/opt/app/letsencrypt/.providers':
    ensure => directory,
    owner  => 'letsencrypt',
    group  => 'letsencrypt',
    mode   => '0700'
  }

  exec {'git-install-acme.sh':
    require => File['/var/opt/app/letsencrypt/acme'],
    creates => '/var/opt/app/letsencrypt/acme/acme.sh',
    command => "/bin/git clone https://github.com/Neilpang/acme.sh.git -b ${hx_website::acme_version} /var/opt/app/letsencrypt/acme",
    notify  => Exec['install-acme.sh']
  }

  exec {'install-acme.sh':
    refreshonly => true,
    command     => "/var/opt/app/letsencrypt/acme/acme.sh --install --home /var/opt/app/letsencrypt/acme --accountemail ${hx_website::maintainer}"
  }

  $hx_website::providers.each | Hash $provider | {

    file {"/var/opt/app/letsencrypt/.providers/.${provider['name']}":
      mode    => '0600',
      owner   => 'letsencrypt',
      group   => 'letsencrypt',
      content => epp('hx_website/provider.epp', {
        provider => $provider['options']
      })
    }

  }

}
