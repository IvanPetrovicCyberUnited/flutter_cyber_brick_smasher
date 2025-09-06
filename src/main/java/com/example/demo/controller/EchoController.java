package com.example.demo.controller;

import jakarta.validation.constraints.Size;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.HtmlUtils;
import java.util.Map;

@RestController
@RequestMapping(value = "/api", produces = MediaType.APPLICATION_JSON_VALUE)
public class EchoController {
    @GetMapping("/echo")
    public Map<String, String> echo(@RequestParam("q") @Size(max = 100) String q) {
        return Map.of("echo", HtmlUtils.htmlEscape(q));
    }
}
