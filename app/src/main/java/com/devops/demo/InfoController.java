package com.devops.demo;

import java.net.InetAddress;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoController {

    private final String version;
    private final String environment;

    public InfoController(@Value("${app.version}") String version,
                          @Value("${app.environment}") String environment) {
        this.version = version;
        this.environment = environment;
    }

    @GetMapping("/")
    public Map<String, String> info() {
        return Map.of(
                "app", "demo-app",
                "version", version,
                "environment", environment,
                "hostname", hostname());
    }

    @GetMapping("/version")
    public Map<String, String> version() {
        return Map.of("version", version);
    }

    private static String hostname() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (Exception e) {
            return "unknown";
        }
    }
}
