#!/bin/bash

sudo apt update -y
echo Update: DONE
echo

sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
echo Upgrade: DONE
echo

###########################################################################
##                          Install MySQL                                ##
###########################################################################

sudo DEBIAN_FRONTEND=noninteractive apt install mysql-server -y
echo MySQL installation: DONE
echo

sudo sed -i 's/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
echo Bind IP Configured: DONE
echo

sudo systemctl restart mysql
echo MySQL restart: DONE
echo

# The users would need to be added manually to prevent hardcoding username and password
cat << 'EOF' > ~/library.sql
DROP DATABASE IF EXISTS library;
CREATE DATABASE library;

USE library;

CREATE TABLE authors (
author_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
full_name VARCHAR(40)
);
CREATE TABLE books (
book_id int  PRIMARY KEY NOT NULL AUTO_INCREMENT,
title VARCHAR(100),
author_id int,
FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

INSERT INTO `library`.`authors` (`full_name`) VALUES ('Phil');
INSERT INTO `library`.`authors` (`full_name`) VALUES ('William Shakespeare');
INSERT INTO `library`.`authors` (`full_name`) VALUES ('Jane Austen');
INSERT INTO `library`.`authors` (`full_name`) VALUES ('Charles Dickens');
EOF

sudo mysql < library.sql
echo DB seeded: DONE
echo

echo MySQL set up: DONE!
echo Task finished
