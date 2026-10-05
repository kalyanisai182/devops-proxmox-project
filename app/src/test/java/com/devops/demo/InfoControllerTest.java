package com.devops.demo;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.util.Map;

import org.junit.jupiter.api.Test;

class InfoControllerTest {

    private final InfoController controller = new InfoController("abc1234", "test");

    @Test
    void infoReturnsVersionEnvironmentAndHostname() {
        Map<String, String> body = controller.info();
        assertEquals("demo-app", body.get("app"));
        assertEquals("abc1234", body.get("version"));
        assertEquals("test", body.get("environment"));
        assertNotNull(body.get("hostname"));
    }

    @Test
    void versionEndpointReturnsVersion() {
        assertEquals("abc1234", controller.version().get("version"));
    }
}
