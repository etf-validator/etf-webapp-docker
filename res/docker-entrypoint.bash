#!/bin/bash

set -x

basicArtifactoryUrl=https://services.interactive-instruments.de/etfdev-af/etf-public-releases

# $1 relative path, $2 egrep regex, $3 destination
getLatestFromII() {
    url=$basicArtifactoryUrl/$1
    eex=$2
    dest=$3
    versionSubPath=$(wget -O- --user=etf-public-releases --password=etf-public-releases $url | grep -v "maven" | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sort -V | tail -1)
    latest=$(wget -O- --user=etf-public-releases --password=etf-public-releases $url/$versionSubPath | egrep -o $eex | sort -V | tail -1)
    echo $latest
    wget -q --user=etf-public-releases --password=etf-public-releases $url/$versionSubPath/$latest -O $dest
    # TODO verifiy checksum
    md5sum $dest
    chown -R jetty:jetty $dest
}

# $1 relative path, $2 egrep regex, $version, $4 destination
getSpecificFromII() {
    url=$basicArtifactoryUrl/$1
    eex=$2
    version=$3
    dest=$4
    versionSubPath=$(wget -O- --user=etf-public-releases --password=etf-public-releases $url | grep -v "maven" | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sort -V | tail -1)
    latest=$(wget -O- --user=etf-public-releases --password=etf-public-releases $url/$versionSubPath | egrep -o $eex | grep $version | tail -1)
    wget -q --user=etf-public-releases --password=etf-public-releases $url/$versionSubPath/$latest -O $dest
    # TODO verifiy checksum
    md5sum $dest
    chown -R jetty:jetty $dest
}

# $1 full path with artifact name and version, $2 destination
getFrom() {
    url=$1
    dest=$2
    wget -q --user=etf-public-releases --password=etf-public-releases $url -O $dest
}

#$1 relative path, $2 egrep, $3 configured value, $4 destination
get() {
    if [ "$3" == "latest" ]; then
        getLatestFromII $1 $2 $4
    else
        getSpecificFromII $1 $2 $3 $4
    fi
}

if [ ! -d "$ETF_DIR" ]; then
    mkdir -p "$ETF_DIR"
    mkdir -p "$ETF_DIR"/bak
    mkdir -p "$ETF_DIR"/td
    mkdir -p "$ETF_DIR"/http_uploads
    mkdir -p "$ETF_DIR"/projects/bsx
    mkdir -p "$ETF_DIR"/projects/sui
    mkdir -p "$ETF_DIR"/testdata
fi

if [ ! -f /var/lib/jetty/webapps/etf-webapp.war ]; then
    get de/interactive_instruments/etf/etf-webapp etf-webapp-[0-9\.]+.war "$ETF_WEBAPP_VERSION" /var/lib/jetty/webapps/etf-webapp.war
fi

if [ ! "$(ls -A $ETF_DIR/ds)" ]; then
    unzip /var/lib/jetty/webapps/etf-webapp.war WEB-INF/etf/ds/* -d /tmp/etf_ds
    mv /tmp/etf_ds/WEB-INF/etf/ds "$ETF_DIR/ds"
    rm -R /tmp/etf_ds
fi

if [ ! -d "$ETF_DIR"/reportstyles ]; then
  get de/interactive_instruments/etf/reportstyle/etf-reportstyle-default/ etf-reportstyle-default-[0-9\.]+.zip "$ETF_DEFAULT_REPORTSTYLE_VERSION" /tmp/etf_reportstyles.zip
  unzip /tmp/etf_reportstyles.zip -d /tmp/etf_reportstyles
  mv /tmp/etf_reportstyles/etf-reportstyle-default-*/ "$ETF_DIR"/reportstyles
  rm -R /tmp/etf_reportstyles.zip
  rm -R /tmp/etf_reportstyles
fi

if [ -n "$ETF_TESTDRIVER_BSX_VERSION" ] && [ "$ETF_TESTDRIVER_BSX_VERSION" != "none" ]; then
  get de/interactive_instruments/etf/testdriver/etf-bsxtd/ etf-bsxtd-[0-9\.]+.zip "$ETF_TESTDRIVER_BSX_VERSION" /tmp/etf_bsxtd.zip
  unzip /tmp/etf_bsxtd.zip -d /tmp/etf_bsxtd
  mv /tmp/etf_bsxtd/bsx "$ETF_DIR"/td/bsx
  rm -R /tmp/etf_bsxtd.zip
  rm -R /tmp/etf_bsxtd
fi

if [ -n "$ETF_TESTDRIVER_SUI_VERSION" ] && [ "$ETF_TESTDRIVER_SUI_VERSION" != "none" ]; then
  get de/interactive_instruments/etf/testdriver/etf-suitd/ etf-suitd-[0-9\.]+.zip "$ETF_TESTDRIVER_SUI_VERSION" /tmp/etf_suitd.zip
  unzip /tmp/etf_suitd.zip -d /tmp/etf_suitd
  mv /tmp/etf_suitd/sui "$ETF_DIR"/td/sui
  rm -R /tmp/etf_suitd.zip
  rm -R /tmp/etf_suitd
fi

if [ ! -f $ETF_WEBAPP_PROPERTIES_FILE ]; then
    unzip /var/lib/jetty/webapps/etf-webapp.war WEB-INF/classes/* -d /tmp/etf_classes
    mv /tmp/etf_classes/WEB-INF/classes/etf-config.properties  $ETF_WEBAPP_PROPERTIES_FILE
    rm -R /tmp/etf_classes/
fi

chown -R jetty:jetty "$ETF_DIR"
set +x
/docker-entrypoint-jetty.bash

exec "$@"
