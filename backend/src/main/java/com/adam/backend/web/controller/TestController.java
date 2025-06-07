package com.adam.backend.web.controller;

import org.springframework.stereotype.Controller;
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
     * hello world
     * @return
     */
    @RequestMapping(path = "/hello.json", method = {RequestMethod.GET}
    , produces = "application/json;charset=UTF-8")
    @ResponseBody
    public Map<String, Object>  hello(){
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "hello world");
        response.put("timestamp", System.currentTimeMillis());
        response.put("serverPort", "8080");
        return response;
    }
}
