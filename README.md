# etf-WebApp docker image

[![etf-webapp](http://dockeri.co/image/iide/etf-webapp)](https://hub.docker.com/r/iide/etf-webapp/)

[![European Union Public Licence 1.2](https://img.shields.io/badge/license-EUPL%201.2-blue.svg)](https://joinup.ec.europa.eu/software/page/eupl)

Docker image of the ETF web application.
ETF is an open source testing framework for testing geo network services and data.
The image is mainly used for testing purposes and therefore the container loads the latest development version. The image is based on the official jetty image. 

Please open a new issue for questions and issues regarding the installation of the docker image [here](https://github.com/etf-validator/etf-webapp-docker/issues).

Please open a new issue for questions and issues regarding the ETF validator [here](https://github.com/etf-validator/etf-webapp/issues).

## Prerequesites

This docker image requires an [installed and configured the docker-engine](https://docs.docker.com/engine/installation/). The image has been tested on Linux machines.

It is recommended to install [docker-compose](https://docs.docker.com/compose/install/) for securing the instance with an
HTTP proxy server and for easier updating.

## Quickstart
To start a new container on port 8080 and create a 'etf' data directory in your
home directory, run the following command:

```CMD
docker run --name etf -d -p 80:8080 -v ~/etf:/etf iide/etf-webapp:latest
```

If you need to change the host data directory,
you must change the first value after the '-v' parameter, for instance
'-v /home/user1/my_etf:etf'.
See the [Docker  documentation](https://docs.docker.com/engine/reference/commandline/run/)
for more information.

The 'docker ps' command should list the running container:

```CMD
$ docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                         NAMES
63affde23fbb        iide/etf-webapp:latest   "/docker-entrypoin..."   2 minutes ago       Up 2 minutes        0.0.0.0:8080->8080/tcp        etf
```

Open your browser and enter the URL (http://localhost/etf-webapp) which should
show the web interface (note that the startup may need some time).

![alt screenshot](https://cloud.githubusercontent.com/assets/13570741/24177217/477aa3c0-0ea1-11e7-8029-59586a607844.png)

## Setup ETF with docker-compose

Make sure you have at least docker-compose version 1.8 installed:

```CMD
docker-compose -v
```

Create a 'etfenv' directory and download the three files:
```CMD
mkdir etfenv && cd etfenv && \
wget https://raw.githubusercontent.com/etf-validator/etf-webapp-docker/master/etfenv/docker-compose.yml && \
wget https://raw.githubusercontent.com/etf-validator/etf-webapp-docker/master/etfenv/htpasswd.txt && \
wget https://raw.githubusercontent.com/etf-validator/etf-webapp-docker/master/etfenv/nginx.conf
```

The compose script will setup a protected nginx webserver (User/Password: etf/etf)
which forwards all requests to the etf-webapp container. The htpasswd.txt and
the _nginx.conf_ files are mounted read only in the container.
You can edit the nginx config file or use [htpasswd](https://httpd.apache.org/docs/current/programs/htpasswd.html) on your linux
machine to create your own credentials.

Unless it is changed in the compose script (docker-compose.yml), the etf-webapp
containers data directory is mounted to _/etf_ on your host system. This can be
changed by editing the first values in the volumes section of the [docker-compose](https://github.com/etf-validator/etf-webapp-docker/blob/master/etfenv/docker-compose.yml#L23-L34)
file. For instance for the directory '/home/user1/my_etf' :

```CMD
 volumes:
  - /home/user1/my_etf/config:/etf/config
  - /home/user1/my_etf/testdata:/etf/testdata
  - /home/user1/my_etf/http_uploads:/etf/http_uploads
  - /home/user1/my_etf/projects:/etf/projects
  - /home/user1/my_etf/bak:/etf/bak
  - /home/user1/my_etf/logs:/etf/logs
  - /home/user1/my_etf/ds/obj:/etf/ds/obj
  - /home/user1/my_etf/ds/attachments:/etf/ds/attachments
```
**Please note that docker-compose.yml is a YAML file and whitespace indentation
is used to denote structure!**

To start the container run:

```CMD
docker-compose up -d
```

On first start, the container will download the latest version of the ETF
from the interactive instruments repository.

The INSPIRE Executable Test Suites are automatically downloaded from the
INSPIRE [ets-repository](https://github.com/inspire-eu-validation/ets-repository) and
installed into the _/etf/projects/inspire-ets-repository_ directory.

The progress can be observed by invoking:
```CMD
docker-compose logs -f
```

Open your browser with the URL (http://localhost) and enter the
credentials (default etf/etf) to access the web interface. If you access the
interface not only from your local machine, you need to edit the
etf-config.properties config file, which will be automatically created on
first startup in the mounted _/etf/config_ directory. Change _localhost_ in the property
_etf.webapp.base.url_ to an IP or a domain name. Afterwards you need to restart
the container:

```bash
docker-compose restart
```

## Log file
The log file etf.log is located in the _/etf/logs_ directory.

## Organization internal proxy server
If outgoing network traffic is filtered by a proxy server in your organization,
you need to configure the container with proxy settings before startup.
The container provides settings for configuring proxy server for HTTP and
HTTP Secure:

```CMD
# Activate HTTP proxy server by setting a host (IP or DNS name).
# Default: "none" for not using a proxy server
HTTP_PROXY_HOST none
# HTTP proxy server port. Default 8080. If you are using Squid it is 3128
HTTP_PROXY_PORT 8080
# Optional username for authenticating against HTTP proxy server or "none" to
# deactivate authentication
HTTP_PROXY_USERNAME none
# Optional password for authenticating against HTTP proxy server or "none"
HTTP_PROXY_PASSWORD none

# Activate HTTP Secure proxy server by setting a host (IP or DNS name).
# Default: "none" for not using a proxy server
HTTPS_PROXY_HOST none
# HTTP Secure proxy server port. Default 3129.
HTTPS_PROXY_PORT 3129
# Optional username for authenticating against HTTPS proxy server or "none" to
# deactivate authentication
HTTPS_PROXY_USERNAME none
# Optional password for authenticating against HTTP Secure proxy server or "none"
HTTPS_PROXY_PASSWORD none
```

These settings can be added in the
[docker-compose](https://github.com/etf-validator/etf-webapp-docker/blob/master/etfenv/docker-compose.yml#L21)
file.

## Update ETF
Run the following commands in the directory of the ETF compose script to stop
and update the container:

```bash
docker-compose stop
docker-compose rm
docker-compose pull
docker-compose up -d
```

This will destroy the container and create a new container with the ETF application.
The _/etf_ data directory does not get deleted -as long as it is mounted on your
host machine!

## Update Executable Test Suites
To update the Executable Test Suites, you can copy the new Executable Test Suites
into the _/etf/projects/_ directory (or the subdirectories). The instance will
automatically reload the Executable Test Suites after some time.

## Custom Executable Test Suites
If you want to deploy your instance directly with custom Executable Test Suites
that are downloaded on container startup, you can change the environment
variable _ETF_TESTPROJECTS_ZIP_ to another URL. See the
[docker-compose.yml environment section](https://github.com/etf-validator/etf-webapp-docker/blob/master/etfenv/docker-compose.yml#L19).
