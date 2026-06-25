package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class DemoApplication {

    // FLAW 1: Hardcoded sensitive credential.
    // Checkmarx (SAST) should flag this immediately as a "Hardcoded Secret" vulnerability.
    private static final String MOCK_PIPELINE_TOKEN = "eGFlMndzM2VkNnJmNXRnNnlodTdpb2s5bHAwYmE="; 

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @GetMapping("/api/v1/test")
    public Map<String, String> getPipelineStatus() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "SUCCESS");
        status.put("message", "Spring Boot Gradle App CI pipeline triggered successfully!");
        return status;
    }

    // FLAW 2: Potential Log Injection / XSS depending on how it's handled.
    // Checkmarx flags unvalidated user inputs passed directly into system outputs.
    @GetMapping("/api/v1/echo")
    public String echoInput(@RequestParam String input) {
        System.out.println("User requested log info for: " + input);
        return "Echoing back: " + input;
    }
}