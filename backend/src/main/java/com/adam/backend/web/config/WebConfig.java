package com.adam.backend.web.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    // 开发环境：不处理静态资源，由前端开发服务器提供
    @Profile("dev")
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 开发环境不注册静态资源处理器
    }

//    // 添加首页重定向
//    @Profile("prod")
//    @Override
//    public void addViewControllers(ViewControllerRegistry registry) {
//        registry.addViewController("/")
//                .setViewName("forward:/index.html");
//    }

//
//    // 生产环境：处理静态资源
//    @Profile("prod")
//    @Override
//    public void addResourceHandlers(ResourceHandlerRegistry registry) {
//        registry.addResourceHandler("/**")
//                .addResourceLocations("classpath:/static/");
//    }
}