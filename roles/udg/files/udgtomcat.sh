#!/bin/bash

set -e

CURRENTDIR=$(pwd)
BUILDDIR=build

mkdir -p ${BUILDDIR}
cp udg-tap.war javamelody-core-1.73.1.jar jrobin-1.5.9.jar ${BUILDDIR}

cd ${BUILDDIR}
rm -rf udg

# download
wget -qc https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.104/bin/apache-tomcat-7.0.104.tar.gz
wget -qc https://ftp.cixug.es/apache//db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-lib.tar.gz
wget -qc https://artifacts.unidata.ucar.edu/repository/unidata-releases/edu/ucar/tds/5.0.0-beta6/tds-5.0.0-beta6.war

tar -xf apache-tomcat-7.0.104.tar.gz
mv apache-tomcat-7.0.104 udg

rm -rf udg/webapps/*
rm -f udg/{BUILDING.txt,CONTRIBUTING.md,LICENSE,README.md,NOTICE,RELEASE-NOTES,RUNNING.txt}

# tds
unzip -q -d udg/webapps/thredds tds-5.0.0-beta6.war
tar -xf db-derby-10.14.2.0-lib.tar.gz -C udg/lib --strip-components=2
cp jrobin-1.5.9.jar javamelody-core-1.73.1.jar udg/webapps/thredds/WEB-INF/lib/

# tap
unzip -q -d udg/webapps/udg-tap udg-tap.war

# package
cd udg
zip -qr udgtomcat.zip *

cd ${CURRENTDIR}
mv ${BUILDDIR}/udg/udgtomcat.zip .
