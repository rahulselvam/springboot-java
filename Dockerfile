# --- Stage 1: Build stage ---
FROM gradle:8.7.0-jdk17 AS builder
WORKDIR /app
COPY build.gradle settings.gradle ./
# Cache dependencies 
RUN gradle dependencies --no-daemon
COPY src ./src
RUN gradle bootJar --no-daemon -x test

# --- Stage 2: Runtime stage ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
# Gradle puts the executable jar inside build/libs/
COPY --from=builder /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]