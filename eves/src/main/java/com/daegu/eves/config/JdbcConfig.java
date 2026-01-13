package com.daegu.eves.config;

import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

@Configuration     //스프링 설정파일로 인식
public class JdbcConfig {
	@Value("#{infoProperty['db.driver']}")     //@Value 설정파일에 설정한 값을 주입
	private String dbDriver;
	
	@Value("#{infoProperty['db.url']}") 
	private String dbUrl;
	
	@Value("#{infoProperty['db.username']}") 	
	private String dbUsername;
	
	@Value("#{infoProperty['db.password']}") 		
	private String dbPassword;	
		
	@Bean   //빈 객체 생성
//	public DriverManagerDataSource dataSource() {
	public DataSource dataSource() {		
		System.out.println("JdbcConfig dataSource()");
		DriverManagerDataSource dataSource=new DriverManagerDataSource();
		dataSource.setDriverClassName(dbDriver);
		dataSource.setUrl(dbUrl);
		dataSource.setUsername(dbUsername);
		dataSource.setPassword(dbPassword);
		return dataSource;
	}

	@Bean
	public JdbcTemplate jdbcTemplate() {
		System.out.println("JdbcConfig jdbcTemplate()");		
		return new JdbcTemplate(dataSource());	
	}
}
