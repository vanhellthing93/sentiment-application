# Stage 1: Сборка с JDK и Maven
FROM maven:3.9.1-eclipse-temurin-17-alpine AS builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Установить binutils с objcopy (для jlink)
RUN apk add --no-cache binutils

RUN $JAVA_HOME/bin/jlink \
    --output /custom-runtime \
    --add-modules java.base,java.logging,java.net.http,java.management,jdk.httpserver \
    --strip-debug \
    --compress=2 \
    --no-header-files \
    --no-man-pages

# Stage 2: минимальный образ scratch с кастомным runtime
FROM alpine:3.17

COPY --from=builder /custom-runtime /custom-runtime
COPY --from=builder /app/target/*.jar ./app.jar

ENTRYPOINT ["/custom-runtime/bin/java", "-jar", "app.jar"]