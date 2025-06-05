package com.adam.backend.web.config;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @ClassName DevForwardController
 * @Package com.adam.backend.web.config
 * @Description TODO
 * @Author adam
 * @Date 6/5/25 5:07 PM
 * @Version 1.0.0
 **/
@Controller
@Profile("dev")
public class DevForwardController {

//    @RequestMapping(value = {"/", "/{path:[^\\.]*}"})
//    public String forward() {
////        return "forward:http://localhost:3000";
//        return "forward:/index.html";
//    }
}
