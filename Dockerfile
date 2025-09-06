# use readOnlyRootFilesystem and no-new-privileges at runtime
FROM eclipse-temurin:21-jre@sha256:3f1b3df0f22a1e8be7cd7e5d9b5c9f3f3f94a639a6a39aea66e68132c0aaf645

WORKDIR /app
RUN adduser --system --group app
USER app

COPY build/libs/security-api-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java","-jar","app.jar"]
