#!/bin/bash

sudo apt update

sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

###########################################################################
##                            Install Nginx                              ##
###########################################################################

# install nginx 
sudo DEBIAN_FRONTEND=noninteractive apt install nginx -y
echo DONE: Install nginx

#Configure nginx
# configure reverse proxy
echo Configure reverse proxy...
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bk
sudo sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://localhost:5000;|' /etc/nginx/sites-available/default
echo DONE: set up proxy
echo

# apply changes to reverse proxy (enable automatic)
echo Apply changes to nginx...
sudo systemctl restart nginx
echo DONE: restart ngnix
echo

###########################################################################
##                            Install Java                               ##
###########################################################################

# install java - check no user input
sudo DEBIAN_FRONTEND=noninteractive apt install openjdk-17-jdk -y
echo DONE: Java installed

# check the version of java
java -version

sudo update-alternatives --config java

# set Java Path
echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> /etc/environment
source /etc/environment
echo $JAVA_HOME
echo DONE: Java env set
echo

###########################################################################
##                            Install Maven                              ##
###########################################################################

# install maven - check for no user input
sudo DEBIAN_FRONTEND=noninteractive apt install maven -y

# check maven installed with version
mvn -version

```
Apache Maven 3.6.3
Maven home: /usr/share/maven
Java version: 17.0.17, vendor: Ubuntu, runtime: /usr/lib/jvm/java-17-openjdk-amd64
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "6.8.0-1040-aws", arch: "amd64", family: "unix"
```
echo DONE: Install maven

###########################################################################
##                     Install Java Spring Boot app                      ##
###########################################################################


git clone https://nettie168:PERSONL-ACCESS-TOKEN@github.com/nettie168/tech515-sparta-java-app-code.git ~/library-app
cd ~/library-app/LibraryProject2

###########################################################################
##                     Set up environment variables                      ##
###########################################################################

export DB_HOST=jdbc:mysql://3.252.196.25:3306/library

export DB_USER=user1

export DB_PASS=password123

###########################################################################
##                     Run Java Spring Boot app                          ##
###########################################################################

# stop app running (if it is already)
# run app in background
mvn spring-boot:stop || true && mvn spring-boot:start