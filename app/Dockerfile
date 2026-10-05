# ---------- Stage 1: build the jar ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src

# Dependencies first: this layer is cached until pom.xml changes
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
# Tests run in their own Jenkins stage, so skip them here
RUN mvn -B -q package -DskipTests

# ---------- Stage 2: minimal runtime image ----------
FROM eclipse-temurin:21-jre

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

RUN useradd --system --uid 10001 --no-create-home appuser
WORKDIR /app
COPY --from=build /src/target/app.jar app.jar

USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/app.jar"]
