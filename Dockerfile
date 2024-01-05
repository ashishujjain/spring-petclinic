# Using debian based JDK image as Java is required for app to launch
FROM openjdk:21-jdk

# Expose a port
EXPOSE 8080

# Artifact file location to be picked for packaging in side container
ARG JAR_FILE=target/spring-petclinic-3.2.0-SNAPSHOT.jar

# Adding the Jar file with the default name
ADD ${JAR_FILE} app.jar

# Set the entry point for the container
ENTRYPOINT ["java","-jar","/app.jar"]
