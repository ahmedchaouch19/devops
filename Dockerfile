# Étape 1 : build
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 : runtime
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/student-management-0.0.1-SNAPSHOT.jar app.jar

# Port correspondant à application.properties
EXPOSE 8089

# Variables d'environnement (optionnel)
ENV SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/studentdb?createDatabaseIfNotExist=true&serverTimezone=UTC
ENV SPRING_DATASOURCE_USERNAME=springuser
ENV SPRING_DATASOURCE_PASSWORD=spring123

ENTRYPOINT ["java","-jar","app.jar"]
