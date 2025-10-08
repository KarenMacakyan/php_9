# Run QloApps locally with Docker

This file explains how to run the QloApps project locally on macOS (zsh) using Docker and Docker Compose.

Prerequisites
- Docker Desktop installed and running
- At least 4GB free memory available

What the compose sets up
- MySQL 8.0 on container `qloapps_db` (host port 3307)
- Apache + PHP 8.1 in `qloapps_web` (host port 8080)
- phpMyAdmin in `qloapps_phpmyadmin` (host port 8081)

Quick start (macOS, zsh)

1. Open a terminal in the project root (where `docker-compose.yml` is).

2. Start the stack:

```bash
docker compose up -d --build
```

3. Wait a few seconds, then open the site installer in your browser:

- Frontend: http://localhost:8080/
- phpMyAdmin: http://localhost:8081/ (user: `root`, password: `rootpassword`)

Database connection details for the installer:

- Host: db
- Port: 3306
- Database: qloapps
- User: qloapps
- Password: qloappspass

Notes
- The project files are mounted into the container; changes on host reflect in the container.
- If your project already has an installation or a `config` file with DB settings, back it up before running the installer.
- Adjust `docker-compose.yml` or `php.ini` if you need different PHP extensions or settings.

Stopping and removing containers

```bash
docker compose down -v
```

Troubleshooting
- If containers fail to start, run `docker compose logs web` and `docker compose logs db` to inspect errors.
- If MySQL refuses connections, ensure no local MySQL instance is binding to port 3307.
