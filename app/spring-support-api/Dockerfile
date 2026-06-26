# syntax=docker/dockerfile:1

# --- Build stage ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# Cache dependencies first
COPY pom.xml .
RUN mvn -q dependency:go-offline

# Build the application jar
COPY src ./src
RUN mvn -q clean package -DskipTests

# --- Runtime stage ---
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

# Run as non-root for a more production-like image
RUN addgroup -S app && adduser -S app -G app

COPY --from=build /build/target/spring-support-api-*.jar app.jar

EXPOSE 8080
USER app

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
