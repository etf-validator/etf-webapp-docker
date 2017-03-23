# Only works with version 9.3.6 or error:
# "...template might not exist or might not be accessible
# by any of the configured Template Resolvers" is thrown
FROM jetty:9.3.6
MAINTAINER Jon Herrmann <herrmann at interactive-instruments.de>

EXPOSE 8080

ENV ETF_DIR /etf
ENV ETF_LOG_DIR /etf/logs

ENV ETF_RELATIVE_URL etf-webapp

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> e.g. “2.0.0” or
# <version as MAJOR.MINOR> e.g. “1.0” to get the latest bugfix version
ENV ETF_WEBAPP_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or
# <version as MAJOR.MINOR>
# Packed with the Webapp
ENV ETF_TESTDRIVER_BSX_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or
# <version as MAJOR.MINOR>
# Packed with the Webapp
ENV ETF_TESTDRIVER_SUI_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or
# <version as MAJOR.MINOR>
# Will be downloaded
ENV ETF_GMLGEOX_VERSION latest

# Default repository configuration
ENV REPO_URL https://services.interactive-instruments.de/etfdev-af/etf-public-releases
ENV REPO_USER etf-public-releases
ENV REPO_PWD etf-public-releases

# Possible values: “none” or URL
ENV ETF_DL_TESTPROJECTS_ZIP https://github.com/inspire-eu-validation/ets-repository/archive/master.zip
# Subfolder in the projects directory
ENV ETF_DL_TESTPROJECTS_DIR_NAME inspire-ets-repository

# Maximum JAVA heap size (XmX parameter) in MB or “max” (max available memory-768MB if at least 3GB available)
ENV MAX_MEM max

RUN mv /docker-entrypoint.bash /docker-entrypoint-jetty.bash
COPY res/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]
