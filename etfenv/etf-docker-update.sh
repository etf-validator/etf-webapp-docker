#!/bin/bash

# Add this file to /etc/sudoers to run this file with sudo etf-docker-update.sh
# without entering a password. Note: never edit the file with a normal
# text editor! Always use the visudo command instead!
# ubuntu        ALL=(ALL)       NOPASSWD: /home/ubuntu/etfenv/etf-docker-update.sh

# Stop container
/usr/local/bin/docker-compose stop

# Delete container
/usr/local/bin/docker-compose rm -f

# Get image updates
/usr/local/bin/docker-compose pull

# Start container in daemon mode
/usr/local/bin/docker-compose up -d
