package com.daegu.eves.quiz;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyQuizStat {
    private LocalDate date;   // YYYY-MM-DD
    private int correctCount; // 그날 맞춘 개수(correct=1)
    private Integer avgScore; // 그날 평균 점수(0~100). 데이터 없으면 null
    private int attempts;     // 그날 전체 시도 수(옵션)
}