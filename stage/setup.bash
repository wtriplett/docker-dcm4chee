#!/bin/sh
set -v

apt-get update -y

# Make the dcm4chee home dir
DCM_ARC_VERSION=2.18.0
DCM_ARR_VERSION=3.0.12
DCM4CHEE_HOME=/var/local/dcm4chee
mkdir -p $DCM4CHEE_HOME
cd $DCM4CHEE_HOME

DCM_DIR=$DCM4CHEE_HOME/dcm4chee-$DCM_ARC_VERSION-mysql

# Patch the JPEGImageEncoder issue for the WADO service
sed -e "s/value=\"com.sun.media.imageioimpl.plugins.jpeg.CLibJPEGImageWriter\"/value=\"com.sun.image.codec.jpeg.JPEGImageEncoder\"/g" < $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml > dcm4chee-wado-xmbean.xml
mv dcm4chee-wado-xmbean.xml $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml

# Update environment variables
echo "\
JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64\n\
PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\n\
" > /etc/environment
