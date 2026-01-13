package com.daegu.eves.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/play/**")
                .addResourceLocations("file:///C:/video/hls/");
        
        registry.addResourceHandler("/profile/**")
        .addResourceLocations("file:///C:/full/workspace/profile/")
        .setCachePeriod(0);
    }
    
    
}
