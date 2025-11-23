# Stage 1: Сборка с JDK и Maven
FROM maven:3.9.1-eclipse-temurin-17-alpine AS builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Создание кастомного Java runtime
RUN $JAVA_HOME/bin/jlink \
    --output /custom-runtime \
    --add-modules java.base,java.logging,java.net.http \
    --strip-debug \
    --compress=2 \
    --no-header-files \
    --no-man-pages

# Stage 2: минимальный образ scratch с кастомным runtime
FROM scratch
WORKDIR /app

COPY --from=builder /custom-runtime /custom-runtime
COPY --from=builder /app/target/*.jar ./app.jar

ENTRYPOINT ["/custom-runtime/bin/java", "-jar", "/app/app.jar"]
