# Deployment of the Java Sprint Boot App

Steps for deployment of the Sparta Java Spring Boot App on an AWS EC2 VM.

### General Method for Java Spring Boot app Deployment with SQL DB
To Run the app 7 stages are needed:

1. Java installed
2. Maven installed (with version compatible with java version)
3. MySQL installed
4. MySQL Path set and running
5. Database created
6. App connected to db 
   - app to know location of database (and have access)
7. App started



# Manual Deployment of Java app

For doing this manually and on an Ubuntu 22.04 EC2 Instance:


**On db EC2**

1. Update OS libraries
2. Install MySQL
   - with `sudo apt install mysql-server`
2. MySQL Path set and enable (is this needed?)
    - by adding the PATH to the system environment variables
    - `sudo systemctl start mysqld` and `sudo systemctl enable mysqld` ??
    - check can access `sudo mysql`
3. Database seeded
   - Create `library.sql`
   - with `library.sql` file using `sudo mysql -u root < library.sql`
  
**On app EC2**

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


## Manual DB deployment

### 1. Update and upgrade OS

### 2. Install MySQL

After install get:
![alt text](image-4.png)

start and enable



'When you install MySQL on Ubuntu, the default username is root, but it often has no password initially or uses the auth_socket plugin, meaning you log in with sudo mysql without typing a password. The password is set during the mysql_secure_installation script, where you create a strong password for the root user and remove anonymous users for security, so there isn't a fixed, pre-set password you need to know. 

Default Login (After Initial Install):
- Username: root
- Password: Often blank (press Enter), or relies on your system user via auth_socket. 
  
#### How to Connect & Secure MySQL:

When you first connect to mysql you don't require a password
- bash `sudo mysql` This uses your Ubuntu user's privileges to log into MySQL as the root user. `exit;` to exit
- shows you can log into mysql without a password (security risk)
  
  #### Add user
  Run Security Script:
- bash `sudo mysql_secure_installation` (sudo uses your Ubuntu user's privileges to log into MySQL as the root user )
  This script will prompt you to:
  1. Ask if you want to enable secure passwords (Check & inform user on how secure their password is and only allow secure passwords to be set) - choose yes 
  2. What level of secure of secure passwords are allowed; low, medium or high?
  3. Inform you that root user is not password protected, as it uses auth_socket by default, and that you can change this ALTER _USER
  4. anonymous users
```
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.
```
5. Only allow root from localhost

```
Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.
```
6. Remove test db
7. Reload privilige tables


```
sudo mysql_secure_installation

Securing the MySQL server deployment.

Connecting to MySQL using a blank password.

VALIDATE PASSWORD COMPONENT can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD component?

Press y|Y for Yes, any other key for No: y

There are three levels of password validation policy:

LOW    Length >= 8
MEDIUM Length >= 8, numeric, mixed case, and special characters
STRONG Length >= 8, numeric, mixed case, special characters and dictionary                  file

Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 0

Skipping password set for root as authentication with auth_socket is used by default.
If you would like to use password authentication instead, this can be done with the "ALTER_USER" command.
See https://dev.mysql.com/doc/refman/8.0/en/alter-user.html#alter-user-password-management for more information.

By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : n

 ... skipping.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
Success.

By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
 - Dropping test database...
Success.

 - Removing privileges on test database...
Success.

Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.

All done!



- Set a strong password for the MySQL root user.
- Remove anonymous users.
- Disallow remote root login.
- Remove the test database.
Connect (With Your New Password):
- bash `mysql -u root -p`
You'll then enter the new password you set in the security script. 
> **Key Takeaway:** Don't expect a default password like 'password' or 'root'; instead, run the security script to set one up for your root user. 
```
### Configure bind IP and restart

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

### Set user and create DB in library.sql
```sql
CREATE USER 'user1'@'172.33.41.15' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON library.* TO 'user1'@'172.33.41.15';
FLUSH PRIVILEGES;
```
The IP being the public IP (or private if on network), of the app EC2. So that a user from there can access the DB. In testing you can also use `%` in place of the IP as it means from anywhere.

And the password being a secure password of > 8 characters, with a mix of capital, lower case, special characters and numbers

See ... script

then run with `sudo mysql < library.sql`


## Manual App Deployment 
#### 1. Update and upgrade OS

`sudo apt update`

`sudo apt upgrade`

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

Check maven installed with version
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

![alt text](image-6.png)

![alt text](image-7.png)

Go to Personal Access Tokens

![alt text](image-1.png)

![alt text](image-2.png)

Click `Generate New Token - (Classic)` 

In note, put in the name eg. `github-nettie-token-exp-feb12`

(as in this case mine said it would expire 12th February)

And click `repo`
![alt text](image-8.png)

Then click `Generate Token`

Copy and paste the token into a file of the same name in `~/.ssh`

Then next time you go to the tokens you'll see

![alt text](image-9.png)

#### 4b. Clone with Personal Access Token

You can now use https to git clone with the personal access token

`git clone https://username:personalAccessToken@github.com/nettie168/tech515-sparta-app.git ~/library-app`

Your username is your github username eg. `nettie168` and you can copy in your personal access token.

It is better to do this manually and not put in a script as this is obviously not secure since you're hard-coding the access token, which means anyone with your script could access the repo.

You could replace it with $GIT_PAT and declare it as an environment variable, however that has the same problems if used in a script or user data. So it's best to do this step manually then use `clear` to remove the access token from your history, and then use an AMI with the app pre-downloaded.


### Connect app to DB

Environment variables are needed as the `application.properties` file uses environment variables DB_HOST, DB_PASS and DB_USER

If in testing on a default vpc then use the public IP of the DB VM, if in production or a custom vpc then use the private IP

`export DB_HOST=jdbc:mysql://54.76.248.61:3306/library`

`export DB_USER=user1`

`export DB_PASS=password123`



Check app can connect to the DB

`mysql -h 54.76.248.61 -u user1 -p` -> if this fails, then the app can't connect to the DB and the app will fail when run

### Run app

In `LibraryProject2` where the `pom.xml` file is run:
`mvn spring-boot:start`

When you got to http://app-public-ip:5000 (not currently using nginx) the app should show:

...

/authors

...


# Automated Deployment with Bash Script

Running the bash scripts

...

`sudo apt update`

`sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y`


# Automated Deployment with AMI

1. Create an AMI from the DB VM
2. Create an AMI from app VM

The DB will have everything installed and configured so no user data is required.

The app will need the environment variables set, and then the app run.

```bash
#!/bin/bash

export DB_HOST=jdbc:mysql://54.76.248.61:3306/library

export DB_USER=user1

export DB_PASS=password123

cd ~/library-app/LibraryProject2

mvn spring-boot:start
```