package com.daegu.eves.quiz;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class QuizResultVo {
    private Integer id;           // PK
    private Integer qid;          // 퀴즈 ID
    private Integer uno;          // 사용자 ID
    private String said;          // 사용자가 말한 원문 텍스트
    private Integer correct;      // 1/0
    private Integer score;        // 0~100
    private LocalDateTime createdAt; // 기록 시각
    private String analysis;  //답변(해석)
}
