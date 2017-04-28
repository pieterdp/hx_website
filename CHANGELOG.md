## Release 1.0.5

#### Summary
- Added autoconfiguration for docroot directories.
- Added default headers.
- Removed dependency on hx_apache.


## Release 1.0.4

#### Summary
This release fixes a grave bug with letsencrypt.

#### Bugfixes
- Fixes bug where config::ssl::letsencrypt would not be included.


## Release 1.0.3

#### Summary
This release fixes some bugs and updates the documentation.

#### Bugfixes
- Remove unused parameter `ca_loc` from documentation.
- Fixes bug where vhost redirects would ignore serveraliases.