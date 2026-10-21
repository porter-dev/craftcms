# Craft CMS on Porter

A minimal Craft CMS 5 project, packaged as a single Docker image with a web service, a queue worker and a predeploy step for migrations.

## What's inside

- Craft CMS 5.11 on PHP 8.4 with Apache (`php:8.4-apache-trixie`), running as `www-data`
- PostgreSQL as the database
- Endpoints:

| Path | Purpose | Needs the database |
| --- | --- | --- |
| `/` | Homepage confirming Craft is running on Porter | Yes |
| `/admin` | Craft control panel | Yes |
| `/healthz` | Liveness check, served by Apache | No |
| `/actions/app/health-check` | Craft's own health check | Yes, and Craft must be installed |

## Run locally

With Docker Compose (Craft plus Postgres):

```sh
cp .env.example .env
echo "CRAFT_SECURITY_KEY=$(openssl rand -hex 32)" >> .env
docker compose up --build -d
docker compose exec web php craft install
```

Open http://localhost:8080 for the site and http://localhost:8080/admin for the control panel. Changes you make in the control panel are written to `config/project/`. Commit that folder so `php craft up` applies them on deploy.

With PHP 8.4 and Composer installed natively, point the `DB_*` variables in `.env` at a local Postgres, then:

```sh
composer install
php craft install
php craft serve 0.0.0.0:8080
```

To build and run only the image:

```sh
docker build -t craftcms . && docker run -p 8080:8080 craftcms
```

`/healthz` responds right away. The rest of the site needs the environment variables below and a database.

## Deploy on Porter

Craft needs a database. Before deploying, create a Postgres datastore in the Porter dashboard under Add-ons. Porter creates an environment group with the same name as the datastore. Attach that group to the app. `config/db.php` reads its `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` and `DB_PASS` variables directly, so you don't need to map any names.

Then create another environment group (or add app environment variables) with `CRAFT_APP_ID`, `CRAFT_SECURITY_KEY` and `PRIMARY_SITE_URL`. For the first deploy, also set `CRAFT_ADMIN_EMAIL` and `CRAFT_ADMIN_PASSWORD`. The predeploy step then installs Craft. You can remove both once the install has run.

### From the dashboard

Fork this repo. In https://dashboard.porter.run, create a new app from your GitHub repo. Porter reads `porter.yaml`, builds the Dockerfile and opens a PR that adds a GitHub Actions workflow. Merge it, and every push to `main` redeploys. See https://docs.porter.run/applications/deploy/deploy-from-github-repo

### From the CLI

Install the CLI (https://docs.porter.run/cli/installation), then:

```sh
porter auth login
porter apply -f porter.yaml
```

## Configuration

`porter.yaml` defines:

- `build`: builds `./Dockerfile` from the repo root.
- `web`: Apache and PHP on port 8080 with 0.5 CPU and 512 MB RAM. Its health check is `/healthz`. The server listens on `$PORT` when that is set, and on 8080 otherwise.
- `worker`: runs `php craft queue/listen` from the same image with 0.25 CPU and 256 MB RAM. Because of this, the image turns off Craft's web based queue runner.
- `predeploy`: runs `bin/predeploy` before each release. If Craft is installed, it runs `php craft up`, which applies migrations and project config. If Craft isn't installed yet and admin credentials are set, it runs `php craft install`. Otherwise it logs a reminder and the deploy continues.

Environment variables:

| Name | Required | Description |
| --- | --- | --- |
| `CRAFT_APP_ID` | Yes | Unique ID for sessions, caches and locks. Generate one with `echo "CraftCMS--$(uuidgen)"` |
| `CRAFT_SECURITY_KEY` | Yes | Key for hashing and encryption. Generate one with `openssl rand -hex 32` and never change it after install |
| `PRIMARY_SITE_URL` | Yes | Public URL of the site, for example `https://craft.example.com` |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS` | Yes | Postgres connection details. These come from the Porter datastore environment group |
| `CRAFT_DB_SERVER`, `CRAFT_DB_DATABASE`, `CRAFT_DB_USER`, `CRAFT_DB_PASSWORD`, `CRAFT_DB_PORT` | No | Craft's own names for the same settings. If set, they take precedence over the `DB_*` values |
| `CRAFT_ADMIN_EMAIL`, `CRAFT_ADMIN_PASSWORD` | First deploy | Admin account the predeploy step creates when Craft isn't installed yet |
| `CRAFT_ADMIN_USERNAME`, `CRAFT_SITE_NAME`, `CRAFT_SITE_LANGUAGE` | No | Install options. The defaults are `admin`, `Craft CMS` and `en-US` |
| `CRAFT_LICENSE_KEY` | No | License key for Craft Team or Pro |
| `CRAFT_ENVIRONMENT` | No | Defaults to `production` in the image |

The container filesystem is ephemeral, so uploaded assets disappear on redeploy. As a next step, add an S3 asset filesystem with the official Amazon S3 plugin (`craftcms/aws-s3`) before you store real media.

Full reference: https://docs.porter.run/applications/configuration-as-code/reference

## Learn more

- https://docs.porter.run/getting-started/quickstart
- https://docs.porter.run/applications/configuration-as-code/overview
- https://docs.porter.run/applications/configure/environment-groups
- https://docs.porter.run/addons/datastores
- https://docs.porter.run/preview-environments/overview
- https://github.com/porter-dev/starters
