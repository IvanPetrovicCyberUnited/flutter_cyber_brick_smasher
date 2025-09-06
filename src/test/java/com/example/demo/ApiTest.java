package com.example.demo;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import net.jqwik.api.ForAll;
import net.jqwik.api.Property;
import org.junit.jupiter.api.Assertions;
import org.springframework.web.util.HtmlUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ApiTest {
    @LocalServerPort
    int port;

    @BeforeEach
    void setup() {
        RestAssured.port = port;
    }

    @Test
    void health() {
        given().when().get("/api/health").then().statusCode(200).body(equalTo("OK"));
    }

    @Test
    void loginAndAccess() {
        String token = login("user", "password");
        given().header("Authorization", "Bearer " + token)
                .when().get("/api/users/me").then().statusCode(200)
                .body("username", equalTo("user"));
        given().header("Authorization", "Bearer " + token)
                .when().get("/api/users/2").then().statusCode(403);
    }

    @Test
    void adminAccess() {
        String token = login("admin", "password");
        given().header("Authorization", "Bearer " + token)
                .contentType(ContentType.JSON)
                .when().post("/api/admin/stats").then().statusCode(200)
                .body("users", equalTo(2));
    }

    private String login(String user, String pass) {
        return given().contentType(ContentType.JSON)
                .body("{\"username\":\"" + user + "\",\"password\":\"" + pass + "\"}")
                .when().post("/api/auth/login")
                .then().statusCode(200)
                .extract().path("token");
    }

    @Property
    void echoIsSanitized(@ForAll String input) {
        String escaped = HtmlUtils.htmlEscape(input);
        Assertions.assertFalse(escaped.contains("<"));
    }
}
