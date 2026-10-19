# Developer Documentation

## Overview

Docker Compose manages three required services, each built from a
project-owned Dockerfile and running in a dedicated container:

-   **NGINX**: HTTPS entry point on port `443`.
-   **WordPress + PHP-FPM**: WordPress application runtime.
-   **MariaDB**: WordPress database.

The services communicate over a dedicated Docker network declared in
`srcs/docker-compose.yml`.

## Prerequisites

``` bash
docker --version
docker compose version
make --version
```

Use a Linux virtual machine and an account permitted to access the
Docker daemon.

## Repository layout

``` text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        ├── wordpress/
        └── mariadb/
```

The exact subdirectories and script names should match the repository.

## Configuration and secrets

1.  Review `srcs/docker-compose.yml`, the Dockerfiles, and
    initialization scripts.
2.  Create `srcs/.env` with every variable referenced by Compose.
3.  Ensure variable names match between Compose and scripts.
4.  Store sensitive values in protected local files or a supported
    secrets mechanism.
5.  Exclude real credentials, `.env`, private keys, and local secret
    files from Git.
6.  Never put passwords in Dockerfiles.

Environment variables suit ordinary configuration. A `.env` file is not
itself a secure secrets manager. The subject recommends Docker secrets
for confidential values; verify the selected mechanism and its access
controls.

## Build and launch

From the repository root:

``` bash
make
```

The Makefile should orchestrate the complete application and build
images through Compose. To validate and launch directly:

``` bash
docker compose -f srcs/docker-compose.yml config
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

Review rendered configuration carefully; depending on the setup, it may
contain interpolated sensitive values. Do not publish it.

## Lifecycle and troubleshooting

``` bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs --tail=100
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker compose -f srcs/docker-compose.yml restart nginx
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml down
```

Before using `docker compose down -v`, inspect the volume definitions
and understand the impact on persistent data.

## Network

Declare a dedicated Docker network. Use service names for internal
communication, for example `mariadb:3306` from WordPress and
`wordpress:9000` from NGINX. Do not use `network_mode: host`, `--link`,
or legacy `links`; the subject forbids them. Only NGINX should be
published to the host on port `443` for the mandatory stack.

## Persistent storage

The database and website files must persist independently of container
writable layers. The subject requires two Docker named volumes stored
under `/home/<login>/data` and explicitly forbids bind mounts for these
two storages.

Verify the final Compose definitions against that requirement. A named
volume configured with `driver_opts` and `o: bind` uses a host bind
mount underneath and should not be described as compliant with the
no-bind-mount rule. Ensure the final storage implementation meets the
subject's wording before evaluation.

Inspect volumes:

``` bash
docker volume ls
docker volume inspect <volume_name>
ls -la /home/dmaestro/data
```

Replace `/home/dmaestro/data` with the correct path if the actual 42
login differs. Do not assume `docker compose down -v` deletes data from
a host directory used as a bind source. Back up data before destructive
operations.

## Validation checklist

-   [ ] Run the project inside a Linux virtual machine.
-   [ ] Build each required service from its own Dockerfile.
-   [ ] Do not use `latest` tags or ready-made application images for
    the mandatory services.
-   [ ] Declare a Docker network; do not use host networking or legacy
    links.
-   [ ] Publish only NGINX on port `443` for the mandatory stack.
-   [ ] Configure TLS 1.2 or TLS 1.3 only.
-   [ ] Use environment variables and a local `.env` without committing
    credentials.
-   [ ] Configure two persistent Docker named volumes according to the
    no-bind-mount requirement.
-   [ ] Configure restart policies.
-   [ ] Create two WordPress users, including an administrator whose
    username does not contain `admin` or `administrator`.
-   [ ] Make the domain resolve to the VM's local IP.
-   [ ] Verify service logs and website access.

## Security

Never commit passwords, tokens, private keys, or secret files. Avoid
exposing MariaDB and PHP-FPM directly to the host. Do not print secret
values in logs. Use restrictive permissions and treat volume removal or
`rm -rf` commands as destructive.
