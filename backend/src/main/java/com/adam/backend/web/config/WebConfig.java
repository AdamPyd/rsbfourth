package com.adam.backend.web.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 转发到前端页面的控制器
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * 添加首页重定向,服务端 jar 接收到请求后，转发到前端页面，响应给浏览器一个前端页面（而不是后端接口的返回结果）
     * @param registry
     */
    @Profile({"dev", "prod"})
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/")
                .setViewName("forward:/index.html");
    }

    /**
     * 生产环境：处理静态资源
     * @param registry
     */
    @Profile("prod")
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/**")
                .addResourceLocations("classpath:/static/");
    }
}