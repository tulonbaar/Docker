# Introduction
This repository is used to store and manage start-up projects for applications on the Docker platform. I intend to adapt most of them to Docker Swarm needs. The repository is divided into folders by application and version. The folder described as swarm is intended for storing configuration files for use with Docker Swarm. 

# Repository structure

The repository contains the following folders:

- `apps` - contains scripts and configuration files for applications
- `apps/keycloak` - contains scripts and configuration files for Keycloak
- `apps/semaphore` - contains scripts and configuration files for Semaphore
- `apps/redis` - contains scripts and configuration files for Redis
- `apps/restapi` - contains scripts and configuration files for REST API
- `apps/osm` - contains scripts and configuration files for OSM    
- `apps/ubuntu` - contains scripts and configuration files for Ubuntu (including the script for downloading and merging maps) - test environment
- `apps/npm` - contains scripts and configuration files for NPM
- `apps/registry` - contains scripts and configuration files for Registry
- `apps/semaphore` - contains scripts and configuration files for Semaphore
- `apps/portainer` - contains scripts and configuration files for Portainer
- `apps/traefik` - contains scripts and configuration files for Traefik
- `apps/tftp` - contains scripts and configuration files for TFTP
- `apps/harbor` - contains scripts and configuration files for Harbor

- `automation` - contains helper scripts that help to run solutions in Docker containers
- `automation/config` - Contains configuration files used by scripts in the `automation` folder. Each configuration takes its name from the script that it refers to.
- `automation/keycloak` - contains helper scripts that help to run Keycloak in a Docker container

- `shared` - contains scripts and files used by multiple applications

- `trash` - contains scripts and files that are no longer used, but serve as references to previous versions of the scripts.

## Scripts
The repository contains scripts that help run solutions in Docker containers. They can be found in the `automation` folder.

<p style="background-color: red">
  WARNING! Scripts assume that the target machine keys are in the default directory `~/.ssh`, and public keys are added to `~/.ssh/authorized_keys`.
</p>

### volume_create.sh
Script for creating volumes. Requires a path to a configuration file with the names of volumes to create and options for creating volumes.

### volume_remove.sh
Script for removing volumes. Requires a path to a configuration file with the names of volumes to remove.

### volume_inspect.sh
Script for inspecting volumes. Requires a path to a configuration file with the names of volumes to inspect.

### send_scripts.sh
Script for sending scripts to other machines. Requires a path to a directory with a configuration file containing the names of the machines.

## Configuration files
The repository contains configuration files that are helpful in running solutions in Docker containers. They are located in the `compose` folders. Most applications require creating network and data resources. The corresponding configurations can be found in `config.yaml` files. Configuration files may contain settings that are not used by all scripts.

### Why?
Well, I noticed in my production environment that some of the NFS resources were created in default path of docker, which is /var/lib/docker/volumes. Not ideal - especially in docker swarm. So I created `automation` folder with scripts to create volumes that are created on all nodes at the same path... Sometimes. Other times I need to recreate volumes few times so they properly connect to NFS server - hence the scripts for removal and inspecting volumes.

# Docker Compose
I usually like to create volumes and networks outside of docker compose file. So most of them are set as external. Please be aware of that fact before using any docker compose file. It gives me more control over where my network is created and where my volumes are created - especially when it comes to NFS volumes.

You can use command below to create volumes:

```bash
    docker volume create --driver local --opt type=nfs --opt o=addr=<NFS_SERVER_IP>,vers=4,rw --opt device=:/<PATH>/<APP_NAME>/volumes/<VOLUME_NAME>
```
You can use command below to create networks:
[Example of creating network](https://docs.docker.com/reference/cli/docker/network/create)

```bash
    docker network create --driver overlay --subnet 10.0.0.0/16 --ip-range 10.0.0.0/16 --gateway 10.0.0.1 --opt encrypted --attachable <NETWORK_NAME>
```

Then you can use:

```compose
volumes:
  volume_name:
    external: true
networks:
  network_name:
    external: true
```
