FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mkdir -p src/main/java src/main/resources
COPY src/main/java ./src/main/java
COPY src/main/resources ./src/main/resources
RUN apk add --no-cache maven && mvn package -DskipTests -Dcheckstyle.skip=true

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]