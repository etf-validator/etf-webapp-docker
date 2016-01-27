# etf-WebApp docker image

[![etf-webapp](http://dockeri.co/image/iide/etf-webapp)](https://hub.docker.com/r/iide/etf-webapp/)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)


Docker image of the etf web application.
ETF is an open source testing framework for testing geo network services and data.
The image is based on the official jetty image.

## Setup etf-webapp with docker-compose
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
