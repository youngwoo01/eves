package com.daegu.eves.lesson;

import java.util.List;

import com.daegu.eves.week.WeekVo;

import lombok.Data;

@Data
public class LessonVo {
	private int lno; // 강의번호
	private int tno; // 강사번호
	private String lname; // 강의 이름
	private String lcate; // 강의분류
	private String llevel; // 강의 레벨
	private String lsum; // 강의 썸네일
	private String ldate; // 강의 등록날짜
	private int lweek; // 강의 주차수
	private int lhit; // 강의 수강수
	
	
	// join
	private String tname; // 강사 이름
	
	// 주차 목록 리스트
	private List<WeekVo> weeks;
	
    // progress는 실시간 계산되는 파생 데이터
    private int progress;  // 진도율
}
