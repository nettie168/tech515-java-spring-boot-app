# Use maven image
FROM maven:3.9.6-eclipse-temurin-17 AS build

# set the working directory as /app
WORKDIR /app

# copy the java-spring boot dependency file first
COPY LibraryProject2/pom.xml .

# run maven
RUN mvn dependency:go-offline

# copy the source file
COPY LibraryProject2/src ./src

# create the package
RUN mvn clean package -DskipTests

# use java image
FROM eclipse-temurin:17-jre

# set the working directory as /app
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

# expose the port
EXPOSE 5000

# run the app.jar
ENTRYPOINT ["java","-jar","app.jar"]