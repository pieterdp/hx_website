# hx_website

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with hx_website](#setup)
    * [What hx_website affects](#what-hx_website-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hx_website](#beginning-with-hx_website)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

Setting up websites is a time-consuming process. This module attempts to make it easier by preconfiguring the [Apache HTTP Web Server](https://httpd.apache.org/) and optionally configuring the website to use [Let's Encrypt](https://letsencrypt.org/) certificates.

This module will install and configure the Apache web server and configure any website you define using `hx_website::website` by creating a new name-based Virtual Host. Optionally, it will also take care of installing new Let's Encrypt certificates.

## Setup

### What hx_website affects

* This module uses the [puppetlabs-apache](https://forge.puppet.com/puppetlabs/apache)-module, so it will automatically purge all (Apache) configuration files not managed by Puppet. It will not be possible to create your own Virtual Hosts, unless you disable the module first.

* If you want to change the configuration of the Apache web server, you must do so in `pp_apache`. Inclusion of `pp_apache` is required before you can use this module.

### Setup Requirements

* Including and configuring `pp_apache` is required before you can use this module.

### Beginning with hx_website

The module consists of two parts: `hx_website` which will do some configuration checks and `hx_website::website` which will configure your website.

The most simple configuration is:

```
class {'hx_website': }
```

Creating a website is done by using the definted type `hx_website::website`:

```
hx_website::website { 'www.example.org':
    vhost_data => {
        servername    => 'www.example.org',
        port          => '80',
        docroot       => '/var/www/www.example.org/hmtl',
        docroot_owner => 'www-data',
        docroot_group => 'www-data',

    }
}
```

This will configure an Apache Virtual Host listening on port 80 for any requests to _www.example.org_, using `/var/www/www.example.org/html` as docroot.

## Usage

### Virtual Hosts
`vhost_data` is passed directly to `apache::vhost`. All valid parameters for that class can appear in `vhost_data`.

`hx_website::website` creates name-based virtual hosts. Two websites can have the same `servername` (inside `vhost_data`), provided the `port` parameter is different. This can be used to create two `hx_website::website`, one HTTP version that redirects to a HTTPS version. This can be done automatically however.

### SSL
To configure SSL-based virtual hosts, you can set either `use_letsencrypt` to `true` (see below) or provide the certificates manually. Note that, if you set `use_letsencrypt`, it will only request certificates when it encounters `port` `433` inside `vhost_data`.

In a lot of cases, you want to redirect any traffic for the non-encrypted site (e.g. http://www.example.org) to the encrypted one (i.e. https://www.example.org). This can be done automatically, if you set `configure_redirect` to true. A new Virtual Host will be created which will redirect all non-encrypted traffic to a HTTPS-version of the `servername` parameter in `vhost_data`.

### Let's Encrypt
It is possible to automatically configure Let's Encrypt, but it comes with some caveats.

After you enable `use_letsencrypt`, but before your first run, you must provide a certificate (it can be the snake-oil certificate) at the location you specified in `vhost_data` (on the client). Otherwise, the Apache web server won't start and `letsencrypt` will fail because it can't check your secret. After the first run and after the certificate has been assigned, it will automatically use the Let's Encrypt-provided one.

## Reference

### Class hx_website
The base class, that must be included and/or configured before you can use `hx_website::website`.

#### Parameters

* `configure_redirect` (default `false`): if you provide a website that is HTTPS (port 443), should we create a redirect from the HTTP version to the HTTPS version.

* `maintainer` (default `hostname@domain`): required for Let's Encrypt: an email address to send expiration notices to. Set this to a working email address if you want to receive them, keep at the default if that isn't necessary.

### Defined type hx_website::website
Configure a website. It will configure an apache Virtual host, and optionally configure Let's Encrypt. Note that you must have a temporary certificate in place at `vhost_data['ssl_cert']` and `vhost_data['ssl_key']` before you attempt to run Puppet if you want a Let's Encrypt certificate. This is because the webserver must be running before a certificate can be requested, and the server will only run if the certificate referred to in the configuration file is already present.

If you don't want Let's Encrypt, you can provide your own certificate. This can be either a certificate present on the Puppet master (recommended) or one on the client. Use `cert_loc` and `key_loc` to specify where it is. Both parameters accept the same settings the `source` parameter of the `file` type uses (as `cert_loc` and `key_loc` are passed directly to `file`->`source`, this should not come as a surprise). If you specified `vhost_data['ssl_ca']`, you can specify `ca_loc`, which will then be used to copy the CA certificate to the `ca_loc` location.

#### Parameters

* `vhost_data`: hash of key-value pairs that is passed directly to `apache::vhost`. Must contain all required parameters for `apache::vhost` and can contain aything this module accepts. It must contain a `servername` and `port` parameter for `hx_website::website` to function however. If you use SSL, you must use port 443 and set `ssl_cert` and `ssl_key` (and even optionally `ssl_ca`).

* `use_letsencrypt` (default: `false`): request a Let's Encrypt certificate. A certificate must be present on the system before requesting a new certificate. Renewal is handled automatically. The root certificate is downloaded, but if you want to use it with your website, you must set `vhost_data['ssl_ca']` to `/etc/ssl/certs/lets-encrypt-x3-cross-signed.pem`.

* `cert_loc` (optional, required only if `use_letsencrypt` is set to `false` and `vhost_data['port']` is set to `443`): location of the certificate file that will be copied to the location referred to in `vhost_data['ssl_cert']`. Accepts the same syntax as `file`->`source`.

* `key_loc` (optional, required only if `use_letsencrypt` is set to `false` and `vhost_data['port']` is set to `443`): location of the key file that will be copied to the location referred to in `vhost_data['ssl_key']`. Accepts the same syntax as `file`->`source`.

* `ca_loc` (optional, only used if `use_letsencrypt` is set to `false` and `vhost_data['port']` is set to `443`): location of the CA certificate file that will be copied to the location referred to in `vhost_data['ssl_ca']`. Accepts the same syntax as `file`->`source`.

### Under-the-hood classes

* `hx_website::config::vhost`: backend class for `hx_website::website`. Accepts the same parameters.

* `hx_website::config::ssl::letsencrypt`: configure Let's Encrypt. Accepts no parameters.

## Limitations

This module was tested on Ubuntu 14.04, but should work with all Ubuntu versions. Only works for Apache >= 2.4.

## Development

Pull requests welcome at [https://github.com/pieterdp/hx_website](https://github.com/pieterdp/hx_website).
