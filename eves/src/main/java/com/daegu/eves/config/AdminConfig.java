package com.daegu.eves.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AdminConfig {

    @Value("#{infoProperty['admin.id']}")
    private String adminId;

    @Value("#{infoProperty['admin.pw']}")
    private String adminPw;

    @Bean(name = "loginType")
    public java.util.Map<String, String> loginType() { // Map 형태({id=admin, pw=1234})로 생성됨
        System.out.println("AdminConfig loginType()");
        java.util.Map<String, String> admin = new java.util.HashMap<>();
        admin.put("id", adminId);
        admin.put("pw", adminPw);
        return admin;
    }
}
