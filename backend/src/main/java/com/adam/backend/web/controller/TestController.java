package com.adam.backend.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * @ClassName TestController
 * @Package com.adam.backend.web.controller
 * @Description TODO
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
    public String hello(){
        return "Hello World";
    }
}
