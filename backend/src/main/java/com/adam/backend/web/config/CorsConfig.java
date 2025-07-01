package com.adam.backend.web.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * @ClassName CorsConfig
 * @Package com.adam.backend.web.config
 * @Description 处理前端跨域问题
 * @Author adam
 * @Date 6/7/25 7:34 PM
 * @Version 1.0.0
 **/
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                // 允许前端开发服务器
                .allowedOrigins(
                        "http://localhost:3000"
                        , "http://localhost:80"
                        , "http://localhost",
                        "http://**:3000"
                        , "http://**:80"
                        , "http://**"
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
