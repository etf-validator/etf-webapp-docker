#!/bin/bash

# Requires:
# -unzip
# -curl
# -wget

set -x

basicArtifactoryUrl=$REPO_URL
appServerDeplPath=/var/lib/jetty/webapps
appServerUserGroup=jetty:jetty

# $1 relative path, $2 egrep regex, $3 destination
getLatestFromII() {
    url=$basicArtifactoryUrl/$1
    eex=$2
    dest=$3
    versionSubPath=$(wget -O- --user=$REPO_USER --password=$REPO_PWD $url | grep -v "maven" | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sort -V | tail -1)
    latest=$(wget -O- --user=$REPO_USER --password=$REPO_PWD $url/$versionSubPath | egrep -o $eex | sort -V | tail -1)
    echo $latest
    wget -q --user=$REPO_USER --password=$REPO_PWD $url/$versionSubPath/$latest -O $dest
    # TODO verifiy checksum
    md5sum $dest
    chown -R $appServerUserGroup $dest
}

# $1 relative path, $2 egrep regex, $version, $4 destination
getSpecificFromII() {
    url=$basicArtifactoryUrl/$1
    eex=$2
    version=$3
    dest=$4
    versionSubPath=$(wget -O- --user=$REPO_USER--password=$REPO_PWD $url | grep -v "maven" | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sort -V | tail -1)
    latest=$(wget -O- --user=$REPO_USER --password=$REPO_PWD $url/$versionSubPath | egrep -o $eex | grep $version | tail -1)
    wget -q --user=$REPO_USER --password=$REPO_PWDs $url/$versionSubPath/$latest -O $dest
    # TODO verifiy checksum
    md5sum $dest
    chown -R $appServerUserGroup $dest
}

# $1 full path with artifact name and version, $2 destination
getFrom() {
    url=$1
    dest=$2
    wget -q --user=$REPO_USER --password=$REPO_PWD $url -O $dest
}

#$1 relative path, $2 egrep, $3 configured value, $4 destination
get() {
    if [ "$3" == "latest" ]; then
        getLatestFromII $1 $2 $4
    else
        getSpecificFromII $1 $2 $3 $4
    fi
}

max_mem_kb=0
xms_xmx=""
if [ -n "$MAX_MEM" ] && [ "$MAX_MEM" != "max" ] && [ "$MAX_MEM" != "0" ]; then
  re='^[0-9]+$'
  if ! [[ $MAX_MEM =~ $re ]] ; then
     echo "MAX_MEM: Not a number" >&2; exit 1
  fi
  max_mem_kb=$(($MAX_MEM*1024))
  xms_xmx="-Xms1g -Xmx${max_mem_kb}k"
else
  # in KB
  max_mem_kb=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')

  # 4 GB in kb
  if [[ $max_mem_kb -lt 4194304 ]]; then
    xms_xmx="-Xms1g"
  else
    # 2 GB for system
    xmx_kb=$(($max_mem_kb-2097152))
    xms_xmx="-Xms2g -Xmx${xmx_kb}k"
  fi
fi

if [[ $max_mem_kb -lt 1048576 ]]; then
  echo "At least 1GB ram is required"
  exit 1;
fi

JAVA_OPTIONS="-server -XX:+UseConcMarkSweepGC -XX:+UseParNewGC $xms_xmx"
export JAVA_OPTIONS
echo "Using JAVA_OPTIONS: ${JAVA_OPTIONS}"

mkdir -p "$ETF_DIR"/bak
mkdir -p "$ETF_DIR"/td
mkdir -p "$ETF_DIR"/logs
mkdir -p "$ETF_DIR"/http_uploads
mkdir -p "$ETF_DIR"/testdata
mkdir -p "$ETF_DIR"/ds/obj
mkdir -p "$ETF_DIR"/ds/appendices
mkdir -p "$ETF_DIR"/ds/attachments
mkdir -p "$ETF_DIR"/ds/db/repo
mkdir -p "$ETF_DIR"/ds/db/data
mkdir -p "$ETF_DIR"/projects

if [ ! -n "$ETF_RELATIVE_URL" ]; then
    ETF_RELATIVE_URL=etf-webapp
fi

if [ ! -f "$appServerDeplPath/$ETF_RELATIVE_URL".war ]; then
    get de/interactive_instruments/etf/etf-webapp etf-webapp-[0-9\.]+.war "$ETF_WEBAPP_VERSION" "$appServerDeplPath/$ETF_RELATIVE_URL".war
fi

if [ ! "$(ls -A $ETF_DIR/ds/db/repo)" ]; then
    unzip -o "$appServerDeplPath/$ETF_RELATIVE_URL".war WEB-INF/etf/ds/* -d /tmp/etf_ds
    rmdir "$ETF_DIR"/ds/db/repo
    mv /tmp/etf_ds/WEB-INF/etf/ds/db/repo "$ETF_DIR/ds/db/repo"
    rm -R /tmp/etf_ds
fi

if [ -n "$ETF_TESTDRIVER_BSX_VERSION" ] && [ "$ETF_TESTDRIVER_BSX_VERSION" != "none" ]; then
  if [ ! -f "$ETF_DIR"/td/etf-bsxtd.jar ]; then
    get de/interactive_instruments/etf/testdriver/etf-bsxtd/ etf-bsxtd-[0-9\.]+.jar "$ETF_TESTDRIVER_BSX_VERSION" /tmp/etf-bsxtd.jar
    mv /tmp/etf-bsxtd.jar "$ETF_DIR"/td
    rm /tmp/etf-bsxtd.jar
  fi
fi

if [ -n "$ETF_TESTDRIVER_SUI_VERSION" ] && [ "$ETF_TESTDRIVER_SUI_VERSION" != "none" ]; then
  if [ ! -f "$ETF_DIR"/td/etf-suitd.jar ]; then
    get de/interactive_instruments/etf/testdriver/etf-suitd/ etf-suitd-[0-9\.]+.jar "$ETF_TESTDRIVER_SUI_VERSION" /tmp/etf-suitd.jar
    mv /tmp/etf-suitd.jar "$ETF_DIR"/td
    rm /tmp/etf-suitd.jar
  fi
fi

if [ ! -f "$ETF_DIR"/ds/db/repo/de/interactive_instruments/etf/bsxm/GmlGeoX.jar ] && [ -n "$ETF_GMLGEOX_VERSION" ] && [ "$ETF_GMLGEOX_VERSION" != "none" ]; then
  get de/interactive_instruments/etf/bsxm/etf-gmlgeox/ etf-gmlgeox-[0-9\.]+.jar "$ETF_GMLGEOX_VERSION" /tmp/GmlGeoX.jar
  mkdir -p "$ETF_DIR"/ds/db/repo/de/interactive_instruments/etf/bsxm/
  mv /tmp/GmlGeoX.jar "$ETF_DIR"/ds/db/repo/de/interactive_instruments/etf/bsxm/
fi

# Download Executable Test Suites
if [ -n "$ETF_DL_TESTPROJECTS_ZIP" ] && [ "$ETF_DL_TESTPROJECTS_ZIP" != "none" ]; then
  curl -LOk "$ETF_DL_TESTPROJECTS_ZIP" -o projects.zip
  mkdir -p "$ETF_DIR"/projects/"$ETF_DL_TESTPROJECTS_DIR_NAME"
  unzip -o projects.zip -d "$ETF_DIR"/projects/"$ETF_DL_TESTPROJECTS_DIR_NAME"
  rm master.zip
fi


chmod 770 -R "$ETF_DIR"/td

chmod 775 -R "$ETF_DIR"/ds/obj
chmod 770 -R "$ETF_DIR"/ds/db/repo
chmod 770 -R "$ETF_DIR"/ds/db/data
chmod 770 -R "$ETF_DIR"/ds/appendices
chmod 775 -R "$ETF_DIR"/ds/attachments

chmod 777 -R "$ETF_DIR"/projects

chmod 775 -R "$ETF_DIR"/http_uploads
chmod 775 -R "$ETF_DIR"/bak
chmod 775 -R "$ETF_DIR"/testdata

touch "$ETF_DIR"/logs/etf.log
chmod 775 "$ETF_DIR"/logs/etf.log

chown -fR $appServerUserGroup $ETF_DIR

if ! command -v -- "$1" >/dev/null 2>&1 ; then
	set -- java -jar "$JETTY_HOME/start.jar" "$@"
fi

if [ "$1" = "java" -a -n "$JAVA_OPTIONS" ] ; then
	shift
	set -- java -Djava.io.tmpdir=$TMPDIR $JAVA_OPTIONS $JAVA_OPTIONS "$@"
fi

exec "$@"
