import org.springframework.boot.gradle.tasks.bundling.BootJar

plugins {
    id("java")
    id("org.springframework.boot") version "3.2.5"
    id("io.spring.dependency-management") version "1.1.4"
    id("jacoco")
    id("checkstyle")
    id("pmd")
    id("com.github.spotbugs") version "6.0.4"
    id("info.solidsoft.pitest") version "1.15.0"
    id("org.owasp.dependencycheck") version "9.0.9"
    id("org.cyclonedx.bom") version "1.7.4"
}

group = "com.example"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web:3.2.5")
    implementation("org.springframework.boot:spring-boot-starter-validation:3.2.5")
    implementation("org.springframework.boot:spring-boot-starter-security:3.2.5")
    implementation("io.jsonwebtoken:jjwt-api:0.11.5")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.11.5")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.11.5")
    implementation("org.springframework.security:spring-security-crypto:6.2.3")
    implementation("com.github.vladimir-bukhtoyarov:bucket4j-core:8.0.1")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0")

    testImplementation("org.springframework.boot:spring-boot-starter-test:3.2.5")
    testImplementation("io.rest-assured:rest-assured:5.4.0")
    testImplementation("net.jqwik:jqwik:1.8.2")
}

configurations.all {
    resolutionStrategy.cacheChangingModulesFor(0, "seconds")
}

jacoco {
    toolVersion = "0.8.12"
}

tasks.test {
    useJUnitPlatform()
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)
        html.required.set(true)
    }
}

spotbugs {
    effort.set(com.github.spotbugs.snom.Effort.MAX)
    reportLevel.set(com.github.spotbugs.snom.Confidence.LOW)
}

pitest {
    junit5PluginVersion.set("1.2.1")
}

checkstyle {
    toolVersion = "10.17.0"
}

pmd {
    toolVersion = "6.55.0"
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
}

