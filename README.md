# etf-WebApp docker image

[![etf-webapp](http://dockeri.co/image/iide/etf-webapp)](https://hub.docker.com/r/iide/etf-webapp/)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)

Docker image of the etf web application.
ETF is an open source testing framework for testing geo network services and data.
The image is based on the official jetty image.

Please open a new issue for questions and issues regarding the installation of the docker image [here](https://github.com/interactive-instruments/etf-webapp-docker/issues).

Please open a new issue for questions and issues regarding the ETF validator [here](https://github.com/interactive-instruments/etf-webapp/issues).

## Prerequesites

This docker image requires an [installed and configured the docker-engine](https://docs.docker.com/engine/installation/). This image has been tested on
Linux machines, on Windows machines you need at least a 64bit Windows 10 with
Hyper-V support. Please see the [ETF wiki](https://github.com/interactive-instruments/etf-webapp/wiki) for alternative installation options.

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
wget https://raw.githubusercontent.com/interactive-instruments/etf-webapp-docker/master/etfenv/docker-compose.yml && \
wget https://raw.githubusercontent.com/interactive-instruments/etf-webapp-docker/master/etfenv/htpasswd.txt && \
wget https://raw.githubusercontent.com/interactive-instruments/etf-webapp-docker/master/etfenv/nginx.conf
```

The compose script will setup a protected nginx webserver (User/Password: etf/etf)
which forwards all requests to the etf-webapp container. The htpasswd.txt and
the _nginx.conf_ files are mounted read only in the container.
You can edit the nginx config file or use (htpasswd)[https://httpd.apache.org/docs/current/programs/htpasswd.html] on your linux
machine to create your own credentials.

Unless it is changed in the compose script (docker-compose.yml), the etf-webapp
containers data directory is mounted to _/etf_ on your host system. This can be
changed by editing the first values in the volumes section of the [docker-compose](https://github.com/interactive-instruments/etf-webapp-docker/blob/master/etfenv/docker-compose.yml#L21-L28)
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

On first start, the container will download the latest version of ETF
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
The _/etf_ data directly does not get deleted -as long as it mounted on your
host machine!

## Update Executable Test Suites
To update the Executable Test Suites, you can copy the new Executable Test Suites
into the _/etf/projects/_ directory (or the subdirectories). The instance will
automatically reload the Executable Test Suites after some minutes.

## Custom Executable Test Suites
If you want to deploy your instance directly with custom Executable Test Suites,
that are downloaded on container startup, you can change the environment
variable _ETF_TESTPROJECTS_ZIP_ to another URL. See the
[docker-compose.yml environment section](https://github.com/interactive-instruments/etf-webapp-docker/blob/master/etfenv/docker-compose.yml#L17-L19).
