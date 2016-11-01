#!/bin/bash
set -v

docker run --link mysql-56:mysql -p 8080:8080 -p 11112:11112 --name="pacs" dcm4chee
