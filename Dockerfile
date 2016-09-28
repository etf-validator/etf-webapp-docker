# Only works with version 9.3.6 or error:
# "...template might not exist or might not be accessible
# by any of the configured Template Resolvers" is thrown
FROM jetty:9.3.6
MAINTAINER Jon Herrmann <herrmann at interactive-instruments.de>

EXPOSE 8080

ENV ETF_DIR /etf
ENV ETF_WEBAPP_PROPERTIES_FILE /etf/etf-config.properties

ENV ETF_RELATIVE_URL etf-webapp

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> e.g. “1.0.3” or <version as MAJOR.MINOR> e.g. “1.0” to get the latest bugfix version
ENV ETF_WEBAPP_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or  <version as MAJOR.MINOR>
ENV ETF_DEFAULT_REPORTSTYLE_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or  <version as MAJOR.MINOR>
ENV ETF_TESTDRIVER_BSX_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or  <version as MAJOR.MINOR>
# TODO temporary disabled, as the ALPHA SoapUI test driver is not yet released
# (planned for the next iteration of the ETF version 2)
ENV ETF_TESTDRIVER_SUI_VERSION none

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or  <version as MAJOR.MINOR>
ENV ETF_GMLGEOX_VERSION latest

# Default repository configuration
ENV REPO_URL https://services.interactive-instruments.de/etfdev-af/etf-public-dev
ENV REPO_USER etf-public-dev
ENV REPO_PWD etf-public-dev

# Possible values: “none”, comma separated list of <URL>s to zip files
# ENV ETF_TESTPROJECTS_REPO none

# Branding text which will appear in the header of the web app
# ENV ETF_BRANDING_TEXT etf-webapp

# Enables simplified workflows (no need to create test objects in an extra step)
# ENV ETF_WORKFLOWS default

# Maximum JAVA heap size (XmX parameter) in MB or “max” (max available memory-768MB if at least 3GB available)
ENV MAX_MEM max

RUN mv /docker-entrypoint.bash /docker-entrypoint-jetty.bash
COPY res/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]
