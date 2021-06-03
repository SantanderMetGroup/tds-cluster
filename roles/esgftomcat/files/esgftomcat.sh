#!/bin/bash

set -e

CURRENTDIR=$(pwd)
BUILDDIR=build
mkdir -p ${BUILDDIR}

cd ${BUILDDIR}

# main components
wget -cq http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.46/bin/apache-tomcat-8.5.46.tar.gz
wget -cq https://github.com/ESGF/esg-orp/releases/download/v2.11.0/esg-orp.war
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/thredds.war
wget -cq https://github.com/ESGF/esgf-idp/releases/download/v2.8.8/esgf-idp.war
wget -cq https://github.com/ESGF/esg-search/releases/download/v4.17.10/esg-search.war

# libraries
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/jdom-legacy-1.1.3.jar
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/commons-httpclient-3.1.jar
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/commons-lang-2.6.jar
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/commons-dbcp-1.4.jar
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/commons-dbutils-1.3.jar
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/commons-pool-1.5.4.jar
wget -cq https://github.com/ESGF/esgf-ansible/releases/download/4.0.0-alpha1/postgresql-8.4-703.jdbc3.jar
wget -cq https://github.com/ESGF/esg-orp/releases/download/v2.11.0/esg-orp-2.11.0.jar
wget -cq https://github.com/ESGF/esgf-security/releases/download/v2.8.11/esgf-security-2.8.11.jar
wget -cq https://github.com/ESGF/esgf-node-manager/releases/download/v1.0.5/esgf-node-manager-common-1.0.5.jar
wget -cq https://github.com/ESGF/esgf-node-manager/releases/download/v1.0.5/esgf-node-manager-filters-1.0.5.jar

# build tomcat
rm -rf tomcat tomcat.zip
mkdir -p tomcat
tar -xf apache-tomcat-8.5.46.tar.gz -C tomcat --strip-components=1 --exclude='webapps/*'
unzip -q -d tomcat/webapps/esg-orp esg-orp.war
unzip -q -d tomcat/webapps/thredds thredds.war
unzip -q -d tomcat/webapps/esgf-idp esgf-idp.war
unzip -q -d tomcat/webapps/esg-search esg-search.war
cp *.jar tomcat/webapps/esg-orp/WEB-INF/lib
cp *.jar tomcat/webapps/thredds/WEB-INF/lib

# copy libraries from orp to thredds
cp tomcat/webapps/esg-orp/WEB-INF/lib/esapi-2.1.0.1.jar tomcat/webapps/thredds/WEB-INF/lib/esapi-2.1.0.1.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/opensaml-2.6.6.jar tomcat/webapps/thredds/WEB-INF/lib/opensaml-2.6.6.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/openws-1.5.6.jar tomcat/webapps/thredds/WEB-INF/lib/openws-1.5.6.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/xmltooling-1.4.6.jar tomcat/webapps/thredds/WEB-INF/lib/xmltooling-1.4.6.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/XSGroupRole-1.0.0.jar tomcat/webapps/thredds/WEB-INF/lib/XSGroupRole-1.0.0.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/commons-collections-3.2.2.jar tomcat/webapps/thredds/WEB-INF/lib/commons-collections-3.2.2.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/not-yet-commons-ssl-0.3.9.jar tomcat/webapps/thredds/WEB-INF/lib/not-yet-commons-ssl-0.3.9.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/serializer-2.9.1.jar tomcat/webapps/thredds/WEB-INF/lib/serializer-2.9.1.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/xalan-2.7.2.jar tomcat/webapps/thredds/WEB-INF/lib/xalan-2.7.2.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/xercesImpl-2.11.0.jar tomcat/webapps/thredds/WEB-INF/lib/xercesImpl-2.11.0.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/xml-apis-1.4.01.jar tomcat/webapps/thredds/WEB-INF/lib/xml-apis-1.4.01.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/xmlsec-1.4.7.jar tomcat/webapps/thredds/WEB-INF/lib/xmlsec-1.4.7.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/joda-time-2.0.jar tomcat/webapps/thredds/WEB-INF/lib/joda-time-2.0.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/commons-io-2.4.jar tomcat/webapps/thredds/WEB-INF/lib/commons-io-2.4.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/slf4j-api-1.7.6.jar tomcat/webapps/thredds/WEB-INF/lib/slf4j-api-1.7.6.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/slf4j-log4j12-1.6.4.jar tomcat/webapps/thredds/WEB-INF/lib/slf4j-log4j12-1.6.4.jar
cp tomcat/webapps/esg-orp/WEB-INF/lib/log4j-1.2.17.jar tomcat/webapps/thredds/WEB-INF/lib/log4j-1.2.17.jar
cp esg-orp-2.11.0.jar tomcat/webapps/thredds/WEB-INF/lib/esg-orp-2.11.0.jar
cp esgf-security-2.8.11.jar tomcat/webapps/thredds/WEB-INF/lib/esgf-security-2.8.11.jar
cp esgf-node-manager-common-1.0.5.jar esgf-node-manager-filters-1.0.5.jar tomcat/webapps/thredds/WEB-INF/lib

# package
cd tomcat
zip -qr ../esgftomcat.zip *

cd ${CURRENTDIR}
mv ${BUILDDIR}/esgftomcat.zip .
