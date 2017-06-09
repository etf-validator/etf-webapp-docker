#!/bin/bash

# Add this file to /etc/sudoers . Note: never edit the file with a normal
# text editor! Always use the visudo command instead!
# ubuntu        ALL=(ALL)       NOPASSWD: /home/ubuntu/etfenv/etf-docker-update.sh
#
# Ensure this file is executable: chmod +x etf-docker-update.sh
# For security reasons the file permissions of the docker-compose.yml file
# should be set to -rwxr-xr-- 1 root root, so that the file can only be
# edited as root user:
# sudo chown root:root docker-compose.yml && sudo chmod 754 docker-compose.yml

# Stop container
/usr/local/bin/docker-compose stop

# Delete container
/usr/local/bin/docker-compose rm -f

# Get image updates
/usr/local/bin/docker-compose pull

# Start container in daemon mode
/usr/local/bin/docker-compose up -d
