#!/bin/bash
set -v

sed -i 's/localhost/'"$PACSDB_PORT_3306_TCP_ADDR"'/g' ${DCM_DIR}/server/default/deploy/pacs-mysql-ds.xml

/stage/update_login_config.py

/usr/bin/mysqld_safe &
/var/local/dcm4chee/dcm4chee-${DCM_ARC_VERSION}-mysql/bin/run.sh
