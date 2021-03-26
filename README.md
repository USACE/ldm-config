# LDM Docker: ldm-config

This repository contains files necessary to build and run a Docker container for Unidata Local Data Manager (LDM) and supports operational configuration for LDM

## Version
----
[`unidata/ldm-docker:6.13.13`](https://hub.docker.com/r/unidata/ldm-docker) from [Docker Hub](https://hub.docker.com)

## Configuring the LDM
----

### Running the configuration with `docker-compose`
---


Running this LDM Docker container is done with [docker-compose](https://docs.docker.com/compose/).

You can customize the provided `docker-compose.yml` to set:

- which ldm image version you want to run (see __Version__ above for current setting)
- which port you want to map to port `388`
- additional configurations through default volumes or any additional volumes you choose

For those that have worked with LDM, you will be familiar with the following directories that are mounted outside the container:

- etc/
- var/data
- var/logs
- var/queues

These directory paths are defined in the `docker-compose.yml`

### Additional Directories
---
You will need to create additional directories defined in the `docker-compose.yml` that are not included in the repository.  These folders are not included due to their possible size and potential `GitHub` limits.  A `.gitignore` lists these directories and files that are not wanted or too large.

- data/
- logs/
- queues/
- queues/ldm.pq

### LDM Configuration Files
---

The `etc` directory has the typical LDM configuration files:

- ldmd.conf
- registry.xml
- scour.conf
- pqact.conf

### Running LDM

    docker-compose up -d ldm

### Stopping LDM

    docker-compose stop

### Checking LDM

You can check the running LDM container with

    docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

The following are examples commands you can run in the running container:

    > docker exec ldm ldmamdin config

    > docker exec ldm ldmadmin restart -v

    > docker exec ldm ldmadmin notifyme -vl- -h idd.unidata.ucar.edu

See the list of commands for `ldmadmin` in the `man` pages or use the command

    docker exec ldm ldmadmin [usage]

### Running LDM commands inside the container

  1. Continue running the commands as described above in [Checking LDM](#Checking-LDM)

    docker exec ldm <shell command>

  2. Enter the container (`docker exec -it <container name or ID> /bin/bash`) and run LDM commands as usual

    docker exec -it ldm /bin/bash

### Citation
---
You can find details on the Unidata Local Data Manager (LDM) system [here](https://doi.org/10.5065/D64J0CT0)

Full details for **LDM Docker** are [here](https://github.com/Unidata/ldm-docker)