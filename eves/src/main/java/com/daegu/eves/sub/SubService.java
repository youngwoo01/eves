package com.daegu.eves.sub;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
public class SubService {

    private final SubDao subDao;
    private static final DateTimeFormatter DF = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public SubService(SubDao subDao) {
        this.subDao = subDao;
    }

    /**
     * 구독 누적 연장:
     *  - baseEnd = MAX(users.send, 오늘)
     *  - newEnd  = baseEnd + planMonth 개월
     *  - sub insert(start=sstart=baseEnd, send=newEnd, sprice, uway)
     *  - users(uchk=1, send=newEnd) 업데이트
     *  - 호출한 SubVo의 sstart/send/sprice를 채워줌 (컨트롤러 세션 갱신용)
     */
    @Transactional
    public void subscribe(SubVo vo) {
        if (vo.getUno() == null) {
            throw new IllegalArgumentException("uno is null");
        }
        if (vo.getPlanMonth() == null || !(vo.getPlanMonth() == 1 || vo.getPlanMonth() == 6 || vo.getPlanMonth() == 12)) {
            throw new IllegalArgumentException("Unsupported planMonth: " + vo.getPlanMonth());
        }
        if (vo.getUway() == null) {
            vo.setUway("CARD"); // 기본 결제수단
        }

        // 1) 현재 종료일 잠금 조회 -> baseEnd 계산
        LocalDate currentSend = subDao.getUserSendForUpdate(vo.getUno()); // null 가능
        LocalDate today = LocalDate.now();
        LocalDate baseEnd = (currentSend == null || currentSend.isBefore(today)) ? today : currentSend;

        // 2) 새 종료일
        LocalDate newEnd = baseEnd.plusMonths(vo.getPlanMonth());

        // 3) 가격 계산 (Java 8 switch)
        int price = calcPrice(vo.getPlanMonth());

        // 4) vo 채우기 (세션 갱신용)
        vo.setSstart(baseEnd.format(DF));
        vo.setSend(newEnd.format(DF));
        vo.setSprice(price);

        // 5) sub 로그 적재
        subDao.insertSub(vo);

        // 6) users 갱신 (uchk=1, send=newEnd)
        subDao.updateUserSubInfo(vo.getUno(), 1, vo.getSend());
    }

    private int calcPrice(int planMonth) {
        switch (planMonth) {
            case 1:  return  8900;
            case 6:  return 46500;
            case 12: return 89000;
            default: throw new IllegalArgumentException("Unsupported planMonth: " + planMonth);
        }
    }
}


//package com.daegu.eves.sub;
//
//import java.time.LocalDate;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//import org.springframework.transaction.annotation.Transactional;
//@Service
//public class SubService {
//	@Autowired
//	private SubDao subDao;
//	public SubService(SubDao subDao) {
//        this.subDao = subDao;
//    }
//
//	 // 구독 처리: 금액 계산 + 종료일 계산 + DB 저장 + uchk,send갱신
//    @Transactional
//    public void subscribe(SubVo vo) {
//
//        // 1) 총 결제금액
//        vo.setSprice(totalPrice(vo.getPlanMonth()));
//
//        // 2) 시작일/종료일 계산 (시작일은 파라미터로 받고, 종료일은 계산)
//        LocalDate start = LocalDate.parse(vo.getSstart());           // yyyy-MM-dd
//        LocalDate end   = start.plusMonths(vo.getPlanMonth()).minusDays(1);
//        vo.setSend(end.toString());                                  // 다시 문자열 저장
//
//        // 3) DB 저장
//        subDao.insertSub(vo);
//   
//        // 4)uchk 계산
//        int uchk = toUchk(vo.getPlanMonth());
//
//        //  DB 업데이트
//        subDao.updateUserSubInfo(vo.getUno(), uchk, vo.getSend());
//        
//    }
//
//    private int totalPrice(int planMonth){
//        if (planMonth == 1)  return  9_900;
//        if (planMonth == 6)  return 46_500;  
//        if (planMonth == 12) return 89_000;
//        throw new IllegalArgumentException("planMonth: "+planMonth);
//    }
//
//    private int toUchk(int planMonth){
//        if (planMonth == 1) return 1;
//        if (planMonth == 6) return 2;
//        if (planMonth == 12) return 3;
//        throw new IllegalArgumentException("planMonth: "+planMonth);
//    }
//	
//
//}
