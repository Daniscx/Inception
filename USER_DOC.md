# User Documentation

## Services

-   **NGINX** receives HTTPS requests on port `443`.
-   **WordPress + PHP-FPM** runs the website.
-   **MariaDB** stores the WordPress database.

The services communicate through a Docker network. MariaDB and PHP-FPM
should not be public entry points.

## Start the project

From the repository root:

``` bash
make
```

If needed, use:

``` bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

## Stop the project

``` bash
docker compose -f srcs/docker-compose.yml down
```

Stopping the stack does not normally delete named volumes or their data.
Do not use a full-clean target or `docker compose down -v` unless you
understand which data will be removed.

## Access the website

-   Website: `https://dmaestro.42.fr`
-   Administration panel: `https://dmaestro.42.fr/wp-admin`

The domain must resolve to the VM's local IP. For access from the VM
itself, `/etc/hosts` can contain:

``` text
127.0.0.1 dmaestro.42.fr
```

For access from another machine, point the domain to the VM's reachable
IP. A local or self-signed TLS certificate may cause a browser warning.

## Credentials

Credentials belong in the local environment/secret files configured for
the project, not in this document or Git.

-   Check `srcs/.env` and/or the configured secret files to see how
    credentials are supplied.
-   Do not publish passwords or commit real credentials.
-   If a password is lost, use the approved password-reset process
    rather than trying to recover plaintext from the database.
-   The WordPress administrator username must not contain `admin` or
    `administrator`, in any capitalization, as required by the subject.

Protect credential files with restrictive permissions and verify that
they are ignored by Git.

## Check service health

``` bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

Follow logs in real time:

``` bash
docker compose -f srcs/docker-compose.yml logs -f
```

Check the HTTPS response:

``` bash
curl -I https://dmaestro.42.fr
```

A TLS verification error may occur with a local certificate. Do not
ignore certificate errors in production.

## Persistent data

The database and WordPress files should persist independently of the
containers' writable layers. Check the final Compose volume definitions
for the actual storage mechanism. Do not manually delete volumes or data
directories unless you intend to reset the installation. Back up the
database and website files before maintenance.
