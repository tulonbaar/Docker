# Introduction
This repository is used to store and manage start-up projects for applications on the Docker platform. I intend to adapt most of them to Docker Swarm needs. The repository is divided into folders by application and version. The folder described as swarm is intended for storing configuration files for use with Docker Swarm. 

# Repository
The repository is divided into folders by application and version. The folder described as swarm is intended for storing configuration files for use with Docker Swarm.

# Scripts
I add all the scripts I use to prepare and start applications to the solutions. The scripts are located in the `_helper_scripts` folder. I recommend using the `send_scripts.sh` script to send these scripts to multiple target machines. Setting SSH keys is necessary. Those solutions that need to have their specific `volume_create` and `volume_remove` scripts are located in the `_helper_scripts` folder inside the application folder.

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

```docker-compose.yaml
volumes:
  volume_name:
    external: true
networks:
  network_name:
    external: true
```
