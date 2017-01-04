# Overview

Packaging of [Roundcube webmail](https://roundcube.net/) 1.1.2 for rumprun.

## Maintainer

* Martin Lucina, mato@rumpkernel.org
* Github: @mato

## Instructions

* Build and `rumprun-bake` the `nginx`, `php` and `mysql` packages.
* With the `roundcube` package:
  * Edit `config/etc-hosts` and `run/*.sh` to suit your network configuration.
  * Edit `config/config.inc.php` to set your IMAP and SMTP configuration.
  * Review `config/nginx/nginx.conf` and optionally provide `config/nginx/cert.{key,pem}`.
  * Run `make`.

Run the built unikernels using the scripts in `run/`:

````
# run/u-nginx-1.sh
# run/u-php-1.sh
# run/u-mysql-1.sh
````
