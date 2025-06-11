package com.adam.backend.web.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

/**
 * @ClassName TestController
 * @Package com.adam.backend.web.controller
 * @Description 测试前后端连通性的控制器
 * @Author adam
 * @Date 6/3/25 11:58 PM
 * @Version 1.0.0
 **/
@Controller
@RequestMapping(path = "/api")
public class TestController {
    /**
     * 获取 spring 配置中的端口
     */
    @Value("${server.port}")
    private String serverPort;

    @GetMapping(path = "/hello.json", produces = "application/json;charset=UTF-8")
    @ResponseBody
    public Map<String, Object> hello() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Hello World!");
        response.put("timestamp", System.currentTimeMillis());
        response.put("serverPort", serverPort);
        return response;
    }

    /**
     * health 健康检查
     * @return
     */
    @GetMapping(path = "/health", produces = "application/json;charset=UTF-8")
    @ResponseBody
    public Map<String, String> healthCheck() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return response;
    }
}
