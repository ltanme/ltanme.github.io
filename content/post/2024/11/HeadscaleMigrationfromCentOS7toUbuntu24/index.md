---
title: "Headscale Migration from CentOS 7 to Ubuntu 24"
date: 2024-11-04T10:00:00+08:00
draft: false
tags: ["headscale", "migration", "docker", "CentOS", "Ubuntu"]
---

This guide covers the process of migrating a Headscale setup from a CentOS 7 system to Ubuntu 24, including steps for exporting configurations, database, and Docker images, as well as importing them on the new system.

### 1. Export Data and Image on CentOS 7

#### Export Configuration and Database
To begin, export the configuration and database files from the `headscale` container:
```bash
docker cp headscale:/etc/headscale/config.yaml ./config.yaml
docker cp headscale:/etc/headscale/db.sqlite ./db.sqlite
```

#### Export Docker Image
Use `docker save` to export the `headscale` Docker image:
```bash
docker save -o headscale_image_backup.tar headscale/headscale:0.23.0-beta1
```

### 2. Transfer Files to Ubuntu 24

Transfer the configuration, database, and image files to the Ubuntu 24 system using `scp`, `rsync`, or another file transfer tool:
```bash
scp config.yaml db.sqlite headscale_image_backup.tar user@ubuntu-server:/path/to/backup/
```

### 3. Import Data on Ubuntu 24

#### Load Docker Image
On the Ubuntu system, use `docker load` to import the Docker image:
```bash
docker load -i /path/to/backup/headscale_image_backup.tar
```

#### Create Headscale Container
Move the configuration and database files to `/etc/headscale/` and create the container:
```bash
sudo mkdir -p /etc/headscale
sudo mv /path/to/backup/config.yaml /etc/headscale/
sudo mv /path/to/backup/db.sqlite /etc/headscale/
```

Run the container with volume mounts:
```bash
docker run -d \
  --name headscale \
  -v /etc/headscale/config.yaml:/etc/headscale/config.yaml \
  -v /etc/headscale/db.sqlite:/etc/headscale/db.sqlite \
  -p 8080:8080 \
  -p 9090:9090 \
  headscale/headscale:0.23.0-beta1
```

### 4. Verify the Migration
Check the container status:
```bash
docker ps
docker logs headscale
```

After completing these steps, Headscale should successfully run on Ubuntu 24.
```
