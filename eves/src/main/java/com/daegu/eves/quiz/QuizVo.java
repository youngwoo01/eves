package com.daegu.eves.quiz;

import lombok.Data;

@Data
public class QuizVo {
    private int qid;        // PK
    private int lno;        // 레슨 번호
    private int wno;        // 주차 번호
    private String qtext;        // 정답 텍스트(문제 텍스트)
    private String ktext;  // 정답 텍스트(한글)
    
}
