FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only the files needed for a reproducible Maven build
COPY pom.xml mvnw ./
COPY .mvn .mvn
COPY src ./src

# Build the application (skip tests for faster image builds)
RUN mvn -B -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built jar from the builder stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app.jar"]
