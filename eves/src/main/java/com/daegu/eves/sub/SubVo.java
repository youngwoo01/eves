package com.daegu.eves.sub;
import java.time.LocalDate;
import lombok.Data;

@Data
public class SubVo {
	private Long   sno;         // PK
    private Long   uno;         // 사용자 번호
    private String sstart;      // 시작일 (yyyy-MM-dd)
    private String send;        // 종료일 (yyyy-MM-dd)
    private Integer sprice;     // 총 결제금액
    private String uway;        // 결제수단: CARD/CASH
    private Integer planMonth;  // 화면용: 1/6/12 (DB 저장 안 해도 됨)

}
