#!/bin/bash
set -v

sed -i 's/localhost/'"$PACSDB_PORT_3306_TCP_ADDR"'/g' ${DCM_DIR}/server/default/deploy/pacs-mysql-ds.xml

/usr/bin/mysqld_safe &
/var/local/dcm4chee/dcm4chee-2.18.0-mysql/bin/run.sh
