#!/bin/bash

set -e
set -x

CURRENTDIR=$(pwd)
BUILDDIR=build

rm -rf ${BUILDDIR}
mkdir -p ${BUILDDIR}
cp udg-tap.war javamelody-core-1.73.1.jar jrobin-1.5.9.jar ${BUILDDIR}

cd ${BUILDDIR}
rm -rf udg

# download
#wget -qc -O tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.62/bin/apache-tomcat-9.0.62.tar.gz
wget -qc -O tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.78/bin/apache-tomcat-8.5.78.tar.gz
wget -qc -O derbydb.tar.gz https://ftp.cixug.es/apache/db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-lib.tar.gz
wget -qc -O tds.war https://downloads.unidata.ucar.edu/tds/5.4/thredds-5.4-SNAPSHOT.war

mkdir udg
tar -C udg --strip-components=1 -xf tomcat.tar.gz

rm -rf udg/webapps/*
rm -f udg/{BUILDING.txt,CONTRIBUTING.md,LICENSE,README.md,NOTICE,RELEASE-NOTES,RUNNING.txt}

# tds
unzip -q -d udg/webapps/thredds tds.war
tar -xf derbydb.tar.gz -C udg/lib --strip-components=2
cp jrobin-1.5.9.jar javamelody-core-1.73.1.jar udg/webapps/thredds/WEB-INF/lib/

# tap
unzip -q -d udg/webapps/udg-tap udg-tap.war

# package
cd udg
zip -qr udgtomcat.zip *

cd ${CURRENTDIR}
mv ${BUILDDIR}/udg/udgtomcat.zip .
