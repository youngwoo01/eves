package com.daegu.eves.teacher;

import java.util.List;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Data
public class TeacherVo {
	private int tno;		//강사번호
	private String tid;		//강사 아이디
	private String tpw;		//강사 비밀번호
	private String tphoto;	//강사 사진
	private String tname;	//강사 이름
	private String tdate;	//강사 가입일
	private String temail;  //강사 이메일
	private String tdescription; // 강사 경력
	private int tchk;		//강사 승인 여부

}
