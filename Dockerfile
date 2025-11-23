# Stage 1: сборка с Maven (+JDK)
FROM maven:3.9.11-eclipse-temurin-17-alpine AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: минимальный runtime образ с JRE Alpine
FROM eclipse-temurin:17-jre-alpine-3.22
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
