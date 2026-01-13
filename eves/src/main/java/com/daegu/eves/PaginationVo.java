 package com.daegu.eves;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class PaginationVo {
	private String display;   // 표시내용
	private int pageNo;		  // 페이지번호
	private int curPage;  	  // 현재 페이지
}
