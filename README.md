# 2-Tier Deployment of ‘Library’ Java Spring Boot App

The following is a runbook for how to deploy the Sparta 'Library' Java Spring Boot app with its SQL database, on a 1. a local Windows machine, 2. a public cloud (AWS EC2), 3. with Docker and 4. using Kubernetes.

- [2-Tier Deployment of ‘Library’ Java Spring Boot App](#2-tier-deployment-of-library-java-spring-boot-app)
    - [Stages of Deployment without Docker](#stages-of-deployment-without-docker)
    - [The app setup locally on a Windows laptop](#the-app-setup-locally-on-a-windows-laptop)
    - [The app set up in 2-tiers on VMs](#the-app-set-up-in-2-tiers-on-vms)
    - [The MySQL database](#the-mysql-database)
    - [The app](#the-app)
- [DevOps Project 6 Stages](#devops-project-6-stages)
    - [Stage 1. Create private repo](#stage-1-create-private-repo)
    - [Stage 2. Deploy locally](#stage-2-deploy-locally)
    - [Stage 3. Deploy on AWS EC2](#stage-3-deploy-on-aws-ec2)
    - [Stage 4. Deploy using Docker](#stage-4-deploy-using-docker)
    - [Stage 5. Deploy using Kubernetes](#stage-5-deploy-using-kubernetes)



### Stages of Deployment without Docker

To run the app 7 stages are needed:

- ✅ 1. MySQL installed
- ✅ 2. MySQL Path set and MySQL running
- ✅ 3. Database created/exists
- ✅ 4. Java installed
- ✅ 5. Maven installed (with version compatible with java version)
- ✅ 6. App connected to the db (app to know location of database (and have access))
- ✅ 7. App started and can connect successfully to db
  

### The app setup locally on a Windows laptop

For learning, the app can be deployed as a monolith (all apps and dbs on the same space) on your laptop.

### The app set up in 2-tiers on VMs

```
   _____Virtual Machine_____                        _____Virtual Machine_____
  |      _____________      |                      |      _____________      |   
  |     |             |     |                      |     |             |     |
  |     |     App     |     |                      |     |   MySQL DB  |     |
  |     |             |     |------>--------<------|     |             |     |
  |     |__port 5000__|     |                      |     |__port 3306__|     |
  |            ^            |                      |            ^            | 
  |      (reverse proxy)    |                      |            |            |
  |_________port 80 ________|                      |_________port 3306_______| 
               ^ public IP
               |
HTTP __________|
            


```
_change to full-screen to view_

The process for running the app is:
```
Spring Boot app starts → connects to DB → runs SQL → starts web server
```
> NOTE: The app will not run without the database, so the DB also needs to be running correctly for the app to work

### The MySQL database

For deployment the most important thing is that the MySQL DB is secured via a username and password, so the app not only needs the DB location but also the username and password

These can be set on MySQL installation, as well as when creating DBs

### The app
The app is built with Java Spring Boot - this means:
- the app is written in java (so dependency #1)
- the app requires maven as a configuration tool to build and manage the project (dependecy #2)
- the app uses a MySQL database (dependency #3)
  
A Java Spring Boot app works is it's own server by using Tomcat, which listens on port 5000 (usually port 8080 for spring boot), so the app will be on location: http://IP-address:5000. A reverse proxy could be used so that users can access the app without declaring the port.

# DevOps Project 6 Stages
### Stage 1. Create private repo
Create a private GitHub repository to store the Java app and SQL script to seed the database (check your course’s Teams channel’s file section for it or ask your trainer for the ‘library-java17-mysql-app' zip file of the app code). Use the README.md file included with the app code to understand the app.

Steps to be found [here](./0-java-SQL-app/README.md)

### Stage 2. Deploy locally

Deploy the app and database on your local machine

Steps to be found [here](./1-deploy-locally/README.md)

### Stage 3. Deploy on AWS EC2

Deploy the app and database on AWS or Azure using Virtual Machines. Automate it via Bash provision scripts that work in user data.

Steps to be found [here](./2-deploy-AWS/README.md)

### Stage 4. Deploy using Docker

Deploy the app and database on AWS or Azure using containers running on a Virtual Machine (Docker Compose). Automate it via Bash provision scripts that work in user data.

Steps to be found [here](./3-deploy-AWS-Docker/README.md)

### Stage 5. Deploy using Kubernetes

Deploy the app and database on AWS or Azure using Kubernetes (Minikube) running on a Virtual Machine. Automate it via Bash provision scripts that work in user data. The Bash scripts could deploy on Kubernetes via applying YAML definition files or (optional) using a Helm chart.

Steps to be found [here](./4-deploy-AWS-Kubernetes/README.md)