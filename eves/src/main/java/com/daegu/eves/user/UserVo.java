package com.daegu.eves.user;

import lombok.Data;

@Data
public class UserVo {
	private int uno;		//회원 번호
	private String uid;		//회원 아이디
	private String upw;		//회원 비밀번호
	private String uname;	//회원 이름
	private String uemail;	//회원 이메일
	private int uchk; 		//회원 구독 여부
	private String send; 	//회원 구독 종료일
}
