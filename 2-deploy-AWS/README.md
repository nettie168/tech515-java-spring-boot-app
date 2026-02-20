# 2-tier Deployment of the Java Spring  Boot App on AWS

Steps for deployment of the Sparta Java Spring Boot App on two AWS EC2 VMs.

- [2-tier Deployment of the Java Spring  Boot App on AWS](#2-tier-deployment-of-the-java-spring--boot-app-on-aws)
  - [General Method for Java Spring Boot app Deployment with SQL DB](#general-method-for-java-spring-boot-app-deployment-with-sql-db)
      - [For DB](#for-db)
      - [For app](#for-app)
  - [Steps for deployment](#steps-for-deployment)
      - [DB Deployment Steps](#db-deployment-steps)
      - [App Deployment Steps](#app-deployment-steps)
    - [App EC2 Requirements for testing](#app-ec2-requirements-for-testing)
  - [DB Deployment](#db-deployment)
    - [1. Update and upgrade OS](#1-update-and-upgrade-os)
    - [2. Install MySQL](#2-install-mysql)
    - [3. Configure bind IP and restart](#3-configure-bind-ip-and-restart)
    - [4. Set user and create DB](#4-set-user-and-create-db)
  - [App Deployment](#app-deployment)
      - [1. Update and upgrade OS](#1-update-and-upgrade-os-1)
      - [2. Install Java](#2-install-java)
      - [2b. Set the PATH](#2b-set-the-path)
    - [3. Install Maven](#3-install-maven)
    - [4. Clone repo with Personal Access Token](#4-clone-repo-with-personal-access-token)
      - [4a. Create a Personal Access Token](#4a-create-a-personal-access-token)
      - [4b. Clone with Personal Access Token](#4b-clone-with-personal-access-token)
    - [5. Connect app to DB](#5-connect-app-to-db)
    - [6. Run app](#6-run-app)
- [Automated Deployment with Bash Script](#automated-deployment-with-bash-script)
- [Automated Deployment with AMI](#automated-deployment-with-ami)

## General Method for Java Spring Boot app Deployment with SQL DB

Steps for deploying on an Ubuntu 22.04 EC2 Instance:

#### For DB

1. MySQL installed
2. MySQL Path set and running
3. Database created

#### For app

1. Java installed
2. Maven installed (with version compatible with java version)
3. App code downloaded
4. App connected to db 
   - app to know location of database (and have access)
5. App started

## Steps for deployment

#### DB Deployment Steps

1. Update OS libraries
2. Install MySQL
   - with `sudo apt install mysql-server`
3. Configure bind IP and restart
4. Add user(s)
5. Database seeded
   - Create `library.sql`
   - with `library.sql` file using `sudo mysql -u root < library.sql`

#### App Deployment Steps

1. Update OS libraries
2. Install nginx and configure reverse proxy
3. Install Java
   - with `sudo apt install openjdk-17-jdk` and set environment variable PATH
4. Install Maven
   - with `apt install maven`
   - and adding the PATH to the system environment variables??
5. Git clone app
   - create ssh key pair to secure repo
   - put public key on github repo and private on EC2 in .ssh
6. Connect app to db 
   - set the environment variables in the `.env`
7. Start app
   - `mvn spring-boot:run`

### App EC2 Requirements for testing

- Ubuntu 22.04
- t3.small
- security groups: 
  - allow ssh from own IP
  - allow HTTP from anywhere
  - allow 5000 from anywhere
  - 
- ### DB EC2 Requirements for testing 

- Ubuntu 22.04
- t3.micro
- security groups: 
  - allow ssh from own IP
  - allow 5000 from anywhere (for testing)

For production put both VMs in custom VPC
- DB is private subnet, no public IP
- app in public subnet
- allow traffic to DB from app security group

ssh into EC2 instance


## DB Deployment

See [prov-sql-db.sh](./prov-sql-db.sh)

### 1. Update and upgrade OS

`sudo apt update && sudo apt upgrade`

### 2. Install MySQL

`sudo DEBIAN_FRONTEND=noninteractive apt install mysql-server -y`

### 3. Configure bind IP and restart

MySQL by default is configured to only allow traffic from localhost. To check what destination it allows traffic from run `sudo ss -tulnp | grep 3306`

If you get 
```
tcp   LISTEN 0      151             127.0.0.1:3306
```

Then it is configured only to localhost and will not allow remote access.

To change this we need to change the bind IP.

`sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf`

nano
/etc/mysql$ sudo nano mysql.conf.d/mysqld.cnf


then change
`bind-address            = 127.0.0.1`
to 
`bind-address            = 0.0.0.0`


> Allowing MySQL to listen on all IP addresses (0.0.0.0 or '%') exposes your server to potential attacks and unauthorized access. So in production when the EC2 are on a custom VPC, the bind IP address with be set at the private IP of the app VM. So only the app VM can access.

Restart MySQL so the changes take affect
`sudo systemctl restart mysql`

Now when the app goes to connect to the DB it will be allowed access.

This can be done automatically with:

`sudo sed -i 's/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf`

### 4. Set user and create DB

```bash
sudo mysql -e "CREATE USER 'user1'@'172.33.41.15' IDENTIFIED BY 'password123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'user1'@'172.33.41.15';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

- where `user1` is the name of your user
- `172.33.41.15` is the IP of the public IP (or private if on network) of the app EC2.
  - So that a user from there can access the DB. In testing you can also use `%` in place of the IP as it means from anywhere.
- and `password123` is the secure password you want to set
  - The password being a secure password of > 8 characters, with a mix of capital, lower case, special characters and numbers

This can also be written directly into sql: 
```sql
CREATE USER 'user1'@'172.33.41.15' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON library.* TO 'user1'@'172.33.41.15';
FLUSH PRIVILEGES;
```

## App Deployment 

See [prov_java_app.sh](./prov_java_app.sh)

#### 1. Update and upgrade OS

`sudo apt update` -> Reach out through internet to find possible updates for OS

`sudo apt upgrade` -> Upgrade these updates

#### 2. Install Java

`sudo DEBIAN_FRONTEND=noninteractive apt install openjdk-17-jdk -y`

`java -version`

You should get a response similar to: 
```
openjdk version "17.0.17" 2025-10-21
OpenJDK Runtime Environment (build 17.0.17+10-Ubuntu-122.04)
OpenJDK 64-Bit Server VM (build 17.0.17+10-Ubuntu-122.04, mixed mode, sharing)
```
Find the path for java:

`sudo update-alternatives --config java`

```
There is only one alternative in link group java (providing /usr/bin/java): /usr/lib/jvm/java-17-openjdk-amd64/bin/java
```

So we know the path for java is at `/usr/lib/jvm/java-17-openjdk-amd64/`

#### 2b. Set the PATH

We're setting the PATH as an environment variable in the environment file, so that the variable persists through each session and is set on boot

nano into `/etc/environment` (which, as it is in root  requires sudo)
`sudo nano /etc/environment`

Paste in `JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64`

Rerun the file, so that the environment variable is set

`source /etc/environment`

Check is the variable was set correctly

`echo $JAVA_HOME`

Should get the result:
```
/usr/lib/jvm/java-17-openjdk-amd64
```

### 3. Install Maven

Maven can be installed just like java with `apt`

`sudo apt install maven`

Check maven installed with version:
`mvn -version`

The result should be similar to:
```
Apache Maven 3.6.3
Maven home: /usr/share/maven
Java version: 17.0.17, vendor: Ubuntu, runtime: /usr/lib/jvm/java-17-openjdk-amd64
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "6.8.0-1040-aws", arch: "amd64", family: "unix"
```

### 4. Clone repo with Personal Access Token
#### 4a. Create a Personal Access Token
To access a private repo you need a personal access token

Go to your GitHub account then Settings > Developer settings

![alt text](./images/image-6.png)

![alt text](./images/image-7.png)

Go to Personal Access Tokens

![alt text](./images/image-1.png)

![alt text](./images/image-2.png)

Click `Generate New Token - (Classic)` 

In note, put in the name eg. `github-nettie-token-exp-feb12`

(as in this case mine said it would expire 12th February)

And click `repo`
![alt text](./images/image-8.png)

Then click `Generate Token`

Copy and paste the token into a file of the same name in `~/.ssh`

Then next time you go to the tokens you'll see

![alt text](./images/image-9.png)

#### 4b. Clone with Personal Access Token

You can now use https to git clone with the personal access token

`git clone https://username:personalAccessToken@github.com/nettie168/tech515-sparta-app.git ~/library-app`

Your username is your github username eg. `nettie168` and you can copy in your personal access token.

It is better to do this manually and not put in a script as this is obviously not secure since you're hard-coding the access token, which means anyone with your script could access the repo.

You could replace it with $GIT_PAT and declare it as an environment variable, however that has the same problems if used in a script or user data. So it's best to do this step manually then use `clear` to remove the access token from your history, and then use an AMI with the app pre-downloaded.


### 5. Connect app to DB

Environment variables are needed as the `application.properties` file uses environment variables DB_HOST, DB_PASS and DB_USER

> NOTE: If in testing on a default vpc then use the public IP of the DB VM, if in production or a custom vpc then use the private IP

`export DB_HOST=jdbc:mysql://54.76.248.61:3306/library`

where the ip is that of the DB

`export DB_USER=user1` -> set your username

`export DB_PASS=password123` -> set your password

Check app can connect to the DB

`mysql -h 54.76.248.61 -u user1 -p` -> if this fails, then the app can't connect to the DB and the app will fail when run

### 6. Run app

In `LibraryProject2` where the `pom.xml` file is run:
`mvn spring-boot:start`

When you got to http://app-public-ip:5000 (not currently using nginx) the app should show:

...

/authors

...


# Automated Deployment with Bash Script

The app and DB cannot be easily deployed straight onto a fresh VM purely with bash scripts because of sensitive information.

The DB VM needs to have a user created with a password, so these need to be done manually, and not hardcoded into a script

```
sudo mysql -e "CREATE USER 'user1'@'%' IDENTIFIED BY 'password1';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'user1'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

And the app VM would need to git clone manually or set an environment variable for the personal access token so that it isn't hardcoded into a script

So to automate the deployment we need the right AMI

# Automated Deployment with AMI

1. Create an AMI from the DB VM
2. Create an AMI from app VM

The DB VM will have MySQL installed and configured with users, so no user data is required.

The app VM will have java and maven installed the app code git cloned with the personal access token (so the personal access token is not hardcoded) and the environment variables set, and then the app run.

It is not advisable to put the username and password into user data

User data:
```bash
#!/bin/bash

export DB_HOST=jdbc:mysql://54.76.248.61:3306/library

export DB_USER=user1

export DB_PASS=password123

cd ~/library-app/LibraryProject2

mvn spring-boot:start
```