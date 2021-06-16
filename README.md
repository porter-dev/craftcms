# Deploy Craft CMS with Porter
This is a quickstart repository you can fork to develop and deploy Craft CMS on Kubernetes on AWS/GCP/DO with Porter.

# Quick Deploy

## Deploying PostgreSQL Database (OPTIONAL) 
This quickstart guide connects Craft CMS to a PostgreSQL database deployed on Porter. You can connect Craft CMS instances deployed on Porter to any external databases, but Porter lets you deploy a PostgreSQL instance in just one click. If you want to connect to a database that's deployed via Porter, please follow [this guide](https://docs.getporter.dev/docs/postgresdb). To seed the deployed database with existing data, you can use Porter's [Remote Execution feature](https://docs.getporter.dev/docs/cli-documentation#remote-execution) to run `psql` commands inside the deployed database.

## Create Environment Group
To allow users to easily reuse the same set of environment variables across deployments, Porter supports **Environment Groups**. In this guide, we will be deploying two services for Craft CMS that use the same set of environment variables - we recommend you to store these as an environment group for convenience.
1. Navigate to the [Environment Group tab](https://dashboard.getporter.dev/env-groups). Create a new environment group by loading in from a file or manually inputting the variables.
2. Ensure that all environment variables outlined below are included. Your `DATABASE` environment variables must match the config of the database you are trying to connect to. If you're trying to connect to a database on Porter, [see this guide for more details.](https://docs.getporter.dev/docs/postgresdb#connecting-to-the-database) 
```
NODE_ENV=production
APP_ID=
SECURITY_KEY=
DATABASE_HOST=
DATABASE_PORT=5432
DATABASE_NAME=
DATABASE_USERNAME=
DATABASE_PASSWORD=
```

## Deploying Craft CMS
1. Create an account on [Porter](https://dashboard.getporter.dev).
2. [One-click provision a Kubernetes cluster](https://docs.getporter.dev/docs/getting-started-with-porter-on-aws) in a cloud provider of your choice, or [connect an existing cluster](https://docs.getporter.dev/docs/cli-documentation#connecting-to-an-existing-cluster) if you already have a cluster.
3. Fork this repository.
4. We will launch two separate services: `web` and `console`. From the [Launch tab](https://dashboard.getporter.dev/launch), navigate to **Web Service > Deploy from Git Repository**. Select the forked repository and `web.Dockerfile` from the root directory. Click **Continue**.
5. Configure the port to `8080`, load in the environment variables from the Environment Group you created in the previous section, then hit deploy.
6. Next we will deploy a `console` service. Navigate to **Worker > Deploy from Git Repository** from the [launch tab](https://dashboard.getporter.dev/launch). Load in the same set of environment variables, then hit deploy.
7. Porter will now automatically handle CI/CD for your Craft CMS deployments whenever you push to the forked repository.

# Development & Propagating Changes
To develop, clone this repository to your local environment and run `docker-compose -f docker-compose.yml up --build` from the root directory.
To propagate your changes to the production environment, you need to run `php craft migrate/all` and `php craft project-config/apply` in one of your deployed services. You can do this via Porter's [Remote Execution feature](https://docs.getporter.dev/docs/cli-documentation#remote-execution). This feature works in a similar way as `ssh` and allows you to run commands inside a deployment.
After you've successfully deployed your changes, you can run these commands to propagate your changes.
```
porter run [DEPLOYMENT_NAME] -- php craft migrate/all
porter run [DEPLOYMENT_NAME] -- php craft project-config/apply
```
Alternatively, if you want to open up an interactive shell instance in the deployment to run other commands, run:
```
porter run [DEPLOYMENT_NAME] -- sh
```

# Questions?
Join the [Porter Discord community](https://discord.gg/FaaFjb6DXA) if you have any questions. For contributions/suggestions to docs, please open an issue in our [open source repository](https://github.com/porter-dev/porter).
