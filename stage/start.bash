#!/bin/bash

set -v

sed -i 's/localhost/'"$PACSDB_PORT_3306_TCP_ADDR"'/g' ${DCM_DIR}/server/default/deploy/pacs-mysql-ds.xml

cd ${DCM_DIR}/server/default/conf/

/stage/update_login_config.py

/usr/bin/mysqld_safe &
${DCM_DIR}/bin/run.sh
