#!/bin/bash

set -v

sed -i 's/localhost/'"$PACSDB_PORT_3306_TCP_ADDR"'/g' \
	${DCM_DIR}/server/default/deploy/pacs-mysql-ds.xml

sed -i 's/localhost/'"$ARRDB_PORT_3306_TCP_ADDR"'/g' \
	${DCM_DIR}/server/default/deploy/arr-mysql-ds.xml

sed -i 's/type=/engine=/g' \
	${ARR_DIR}/sql/dcm4chee-arr-mysql.ddl

cd ${DCM_DIR}/server/default/conf/

python /stage/update_login_config.py

echo "Waiting for pacsdb"
until \
mysql -h"$PACSDB_PORT_3306_TCP_ADDR" -P"$PACSDB_PORT_3306_TCP_PORT" \
	-uroot -p"$PACSDB_ENV_MYSQL_ROOT_PASSWORD" &> /dev/null
do
  printf "."
  sleep 1
done

echo -e "\nmysql ready."

if [[ ! -e /.db_creation_complete ]]; then

	echo "Creating DBs..."
	mysql -h"$PACSDB_PORT_3306_TCP_ADDR" -P"$PACSDB_PORT_3306_TCP_PORT" \
		-uroot -p"$PACSDB_ENV_MYSQL_ROOT_PASSWORD" < /stage/create_dcm4chee_databases.sql

	mysql -h"$PACSDB_PORT_3306_TCP_ADDR" -P"$PACSDB_PORT_3306_TCP_PORT" \
		-uroot -p"$PACSDB_ENV_MYSQL_ROOT_PASSWORD" arrdb < ${ARR_DIR}/sql/dcm4chee-arr-mysql.ddl

	echo "Initializing DBs."
	mysql -h"$PACSDB_PORT_3306_TCP_ADDR" -P"$PACSDB_PORT_3306_TCP_PORT" \
		-uroot -p"$PACSDB_ENV_MYSQL_ROOT_PASSWORD" pacsdb < ${DCM_DIR}/sql/create.mysql

	touch /.db_creation_complete

fi

${DCM_DIR}/bin/run.sh
