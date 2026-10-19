*This project has been created as part of the 42 curriculum by dmaestro.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. Its
goal is to build a small web infrastructure with Docker Compose inside a
virtual machine.

The mandatory stack contains three services, each running in its own
container:

-   **NGINX**: the only public entry point, serving HTTPS on port `443`
    with TLS 1.2 or TLS 1.3.
-   **WordPress + PHP-FPM**: runs the WordPress application without
    NGINX.
-   **MariaDB**: stores the WordPress database without NGINX.

The services communicate through a dedicated Docker network. The project
uses custom Dockerfiles and a root-level Makefile to build and start the
infrastructure.

> **Validation checks:** The subject requires the WordPress
> administrator username not to contain `admin` or `administrator` in
> any capitalization. If the initialization script still creates a user
> named `admin`, change it before evaluation. The subject also
> explicitly requires Docker named volumes and forbids bind mounts for
> the two persistent storages. If the current volume definitions use
> `driver_opts` with `o: bind`, review and change them before claiming
> compliance.

## Project structure

The repository should include at least the following documentation and
configuration files. Adjust service filenames to match the actual
repository.

``` text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                  # local secrets; never commit real credentials
└── srcs/
    ├── .env                  # local configuration; do not commit real credentials
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        └── mariadb/
            ├── Dockerfile
            └── tools/
```

## Main design choices

### Virtual Machines vs Docker

A virtual machine virtualizes a complete computer and runs its own guest
operating system and kernel. Docker containers isolate applications and
processes while normally sharing the host kernel. Containers are
generally lighter to start, while virtual machines provide a separate
guest OS. In this project, the infrastructure runs inside a VM as
required by the subject, and Docker Compose manages the services inside
it.

### Secrets vs Environment Variables

Environment variables provide application configuration, such as the
domain, database name, database host, and usernames. A `.env` file helps
configure Compose but is not, by itself, a secure secret store.
Passwords and other confidential values should be stored in protected
secret files or a supported secrets mechanism. Never commit real
credentials, API keys, or private keys to Git. Ensure `.env` and local
secret files are ignored by Git and have restrictive permissions.

### Docker Network vs Host Network

A dedicated Docker network lets containers communicate through service
names, for example WordPress connecting to `mariadb:3306` and NGINX
forwarding FastCGI requests to `wordpress:9000`. Host networking shares
the host's network namespace and reduces network isolation. The subject
forbids host networking, `--link`, and legacy `links`; therefore,
declare a dedicated Docker network. Only NGINX should be publicly
exposed, on port `443`.

### Docker Volumes vs Bind Mounts

A Docker named volume is managed by Docker and can persist independently
of a container's writable layer. A bind mount maps a specific host path
directly into a container and depends on that host path and its
permissions. The subject requires two named volumes for the database and
website files, with storage under `/home/<login>/data`, and explicitly
forbids bind mounts for these storages. The final Compose configuration
must meet both requirements. Removing a container normally preserves
named-volume data; removing the volumes or deleting underlying data can
be destructive.

## Requirements

-   Run the project inside a Linux virtual machine.
-   Use Docker Compose and custom Dockerfiles for NGINX,
    WordPress/PHP-FPM, and MariaDB.
-   Build the required service images locally; do not use ready-made
    application images for the mandatory services.
-   Use a permitted Debian or Alpine base version and do not use the
    `latest` tag.
-   Run each service in its own container.
-   Declare a dedicated Docker network.
-   Configure NGINX as the only public entry point, on port `443` only,
    using TLS 1.2 or TLS 1.3.
-   Use environment variables and a `srcs/.env` file, without committing
    credentials.
-   Configure two persistent named volumes according to the subject's
    no-bind-mount requirement.
-   Configure containers to restart after a crash.
-   Create two WordPress users, including an administrator whose
    username does not contain `admin` or `administrator`.

## Instructions

### Prerequisites

-   A Linux virtual machine.
-   Docker Engine and Docker Compose v2 (`docker compose`).
-   `make`.

### Domain setup

The subject requires `<login>.42.fr`. This configuration uses
`dmaestro.42.fr`. Add the following to `/etc/hosts` on the VM if it is
not already present:

``` text
127.0.0.1 dmaestro.42.fr
```

Use the VM's reachable local IP instead of `127.0.0.1` when accessing
the website from another machine.

### Environment configuration

Create `srcs/.env` with the variable names referenced by
`srcs/docker-compose.yml` and the initialization scripts. Typical
settings include the domain, database name, database user and passwords,
WordPress user, and email. Keep actual passwords out of this README.
Ensure variable names match across Compose and scripts, protect local
configuration, and exclude credentials from Git.

### Build and start

From the repository root:

``` bash
make
```

The Makefile should prepare any required directories and build/start the
application using Docker Compose. If needed, use the equivalent
commands:

``` bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

### Inspect and stop

``` bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml down
```

Use the Makefile targets if provided. Check what a full-clean target
deletes before running it.

### Access

-   Website: `https://dmaestro.42.fr`
-   WordPress administration: `https://dmaestro.42.fr/wp-admin`

A browser may warn about a locally generated or self-signed certificate.
Verify that NGINX serves the expected certificate and TLS configuration.

## Security notes

-   Do not commit passwords, `.env` files containing real credentials,
    private keys, or secret files.
-   Do not put passwords in Dockerfiles.
-   Do not expose MariaDB or PHP-FPM directly to the host for the
    mandatory stack.
-   Use restrictive permissions for secrets and persistent data.
-   Treat `docker compose down -v` and `rm -rf` as potentially
    destructive. A host directory used as a bind source is not
    automatically emptied by `docker compose down -v`.

## Resources

-   [Docker documentation](https://docs.docker.com/)
-   [Docker Compose documentation](https://docs.docker.com/compose/)
-   [Docker volumes](https://docs.docker.com/engine/storage/volumes/)
-   [Bind mounts](https://docs.docker.com/engine/storage/bind-mounts/)
-   [Docker networking](https://docs.docker.com/engine/network/)
-   [Docker Compose
    secrets](https://docs.docker.com/compose/how-tos/use-secrets/)
-   [NGINX documentation](https://nginx.org/en/docs/)
-   [WordPress documentation](https://wordpress.org/documentation/)
-   [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
-   [PHP documentation](https://www.php.net/docs.php)

### AI usage

AI assistance was used to help structure and review documentation,
explain Docker concepts, and improve the clarity of instructions.
Configuration details and commands must be checked against the actual
repository and tested in the target VM. The project author remains
responsible for understanding, validating, and explaining the
implementation during peer evaluation.
