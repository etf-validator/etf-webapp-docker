# etf-WebApp docker image

[![etf-webapp](http://dockeri.co/image/iide/etf-webapp)](https://hub.docker.com/r/iide/etf-webapp/)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![](https://badge.imagelayers.io/iide/etf-webapp:latest.svg)](https://imagelayers.io/?images=iide/etf-webapp:latest 'Get your own badge on imagelayers.io')



Docker image of the etf web application.
ETF is an open source testing framework for testing geo network services and data.
The image is based on the official jetty image.
Please [open a new issue for questions and issues regarding the installation of the docker image](https://github.com/interactive-instruments/etf-webapp-docker/issues). Please [open a new issue for questions and issues regarding the ETF Validator](https://github.com/interactive-instruments/etf-webapp/issues).

## Install etf-webapp version 1 (stable version, used in the ELF project)

### Setup etf-webapp with docker-compose
Make sure you have installed
[docker-compose](https://docs.docker.com/compose/install/). The compose script can be found in the
_[etfenv](https://github.com/interactive-instruments/etf-webapp-docker/tree/master/etfenv)_ directory.

The compose script will setup a protected nginx webserver (User/Password: etf/etf)
which forwards all requests to the etf-webapp container. The htpasswd.txt and
the _nginx.conf_ files are mounted read only in the container.
You can edit the config file or use _htpasswd_ to create credentials.

Unless it is changed in the compose script, the etf-webapp containers
data directory is mounted to _/etf_ on your host system. On first start, the container will download
the latest etf-webapp from the interactive instruments repository.
Set the URL to the server in the _etf-config.properties_ file. The file is also mounted read only in the container.

Start both containers with:
```bash

docker-compose up -d
```

### Install Test Projects (Executable Test Suites)
Copy BaseX-based test projects to the _/etf/projects/bsx_ directory, SoapUI-based test projects to the _/etf/projects/sui_ directory. A restart of the container is not required, since test projects are reloaded automatically after a few seconds.

## Install etf-webapp version 2 (preview version, not for production use)

### Setup with docker-compose
Follow the same installation instructions like above, but use the _[compose script from the development repository](https://github.com/interactive-instruments/etf-webapp-docker/tree/dev/etfenv)_.

### Install the INSPIRE Executable Test Suites
The Executable Test Suites are automatically downloaded from the [ets-repository](https://github.com/inspire-eu-validation/ets-repository) and installed into the _/etf/projects_ directory.

### Update
Run the following commands in the directory of the ETF compose script
```bash
docker-compose stop
docker-compose rm
docker-compose up -d
```

