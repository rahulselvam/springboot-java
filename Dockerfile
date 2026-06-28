# --- Stage 1: Build stage ---
FROM gradle:8.7.0-jdk17 AS builder
WORKDIR /app

# Copy configuration files first to lock in the layer cache for dependencies
COPY build.gradle settings.gradle ./

# Cache dependencies cleanly without running full tasks
RUN gradle build -x test --no-daemon > /dev/null 2>&1 || true

# Copy source files (changing this will invalidate the cache from this line onward)
COPY src ./src
RUN gradle bootJar --no-daemon -x test

# --- Stage 2: Runtime stage ---
# Using the lean Alpine footprint to reduce your attack surface area
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Safely copy the compiled fat jar from the builder environment
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]