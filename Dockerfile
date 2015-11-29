#
# DCM4CHEE - Open source picture archive and communications server (PACS)
#
FROM ubuntu:12.04
MAINTAINER AI Analysis, Inc <admin@aianalysis.com>

# Load the stage folder, which contains the setup scripts.
#
ENV DCM_ARC_VERSION 2.18.0
ENV DCM_ARR_VERSION 3.0.12
ENV DCM4CHEE_HOME /var/local/dcm4chee

RUN apt-get update && apt-get install -yq --no-install-recommends \
    curl zip mysql-server openjdk-6-jdk

ADD stage stage
# Download the binary package for DCM4CHEE
RUN curl -G http://ufpr.dl.sourceforge.net/project/dcm4che/dcm4chee/$DCM_ARC_VERSION/dcm4chee-$DCM_ARC_VERSION-mysql.zip > /stage/dcm4chee-$DCM_ARC_VERSION-mysql.zip
RUN unzip -q /stage/dcm4chee-$DCM_ARC_VERSION-mysql.zip
ENV DCM_DIR $DCM4CHEE_HOME/dcm4chee-$DCM_ARC_VERSION-mysql

# Download the binary package for JBoss
RUN curl -G http://ufpr.dl.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA-jdk6.zip > /stage/jboss-4.2.3.GA-jdk6.zip
RUN unzip -q /stage/jboss-4.2.3.GA-jdk6.zip
ENV JBOSS_DIR $DCM4CHEE_HOME/jboss-4.2.3.GA

# Download the Audit Record Repository (ARR) package
RUN curl -G http://ufpr.dl.sourceforge.net/project/dcm4che/dcm4chee-arr/$DCM_ARR_VERSION/dcm4chee-arr-$DCM_ARR_VERSION-mysql.zip > /stage/dcm4chee-arr-$DCM_ARR_VERSION-mysql.zip
RUN unzip -q /stage/dcm4chee-arr-$DCM_ARR_VERSION-mysql.zip
ENV ARR_DIR $DCM4CHEE_HOME/dcm4chee-arr-$DCM_ARR_VERSION-mysql

# Copy files from JBoss to dcm4chee
RUN $DCM_DIR/bin/install_jboss.sh jboss-4.2.3.GA > /dev/null

# Copy files from the Audit Record Repository (ARR) to dcm4chee
RUN $DCM_DIR/bin/install_arr.sh dcm4chee-arr-$DCM_ARR_VERSION-mysql > /dev/null

# Install and set up MySQL
RUN mysql_install_db
RUN /usr/bin/mysqld_safe &
RUN sleep 5s
# Create the 'pacsdb' and 'arrdb' databases, and 'pacs' and 'arr' DB users.
RUN mysql -uroot < /stage/create_dcm4chee_databases.sql
# Load the 'pacsdb' database schema
RUN mysql -upacs -ppacs pacsdb < $DCM_DIR/sql/create.mysql
# The ARR setup script needs to be patched
RUN sed "s/type=/engine=/g" $ARR_DIR/sql/dcm4chee-arr-mysql.ddl > fixed.ddl
RUN mv fixed.ddl $ARR_DIR/sql/dcm4chee-arr-mysql.ddl
# Load the 'arrdb' database schema
RUN mysql -uarr -parr arrdb < $ARR_DIR/sql/dcm4chee-arr-mysql.ddl
RUN killall mysqld
RUN sleep 5s

ADD stage stage
RUN chmod 755 stage/*.bash
RUN cd stage; ./setup.bash

CMD ["stage/start.bash"]
