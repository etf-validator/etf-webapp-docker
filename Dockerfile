FROM jetty:9.3.6
MAINTAINER Jon Herrmann <herrmann at interactive-instruments.de>

EXPOSE 8080

ENV ETF_DIR /etf
ENV ETF_WEBAPP_PROPERTIES_FILE /etf/etf-config.properties

# All ETF artifacts are searched in https://services.interactive-instruments.de/etfdev-af/etf-public-releases/

ENV ETF_RELATIVE_URL etf-webapp

# Possible values: “latest” or <version>
ENV ETF_WEBAPP_VERSION latest

# Possible values: “latest” or <version>
ENV ETF_DEFAULT_REPORTSTYLE_VERSION latest

# Possible values: “none”, “latest” or <version>
ENV ETF_TESTDRIVER_BSX_VERSION latest

# Possible values: “none”, “latest” or <version>
ENV ETF_TESTDRIVER_SUI_VERSION latest

# Possible values: “none”, “latest” or <version>
ENV ETF_GMLGEOX_VERSION latest

# Possible values: “none”, comma separated list of <URL>s to zip files
# ENV ETF_TESTPROJECTS none

# Branding text which will appear in the header of the web app
# ENV ETF_BRANDING_TEXT etf-webapp

# Enables simplified workflows (no need to create test objects)
# ENV ETF_SIMPLIFIED_WORKFLOWS true

RUN mv /docker-entrypoint.bash /docker-entrypoint-jetty.bash
COPY res/docker-entrypoint.bash /
