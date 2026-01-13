package com.daegu.eves.pdf;

import lombok.Data;

@Data
public class PdfVo {
    private int pno;// 자료번호
    private int lno;// 강의번호
    private int wno;// 주차번호
    private String pupdf;// 자료 업로드명 (고유 이름)
    private String pdpdf;// 자료 다운로드명 (원본 이름)
    private String pdate;// 자료 등록일
}
