// 예: com.daegu.ex1.user.TeacherServiceImpl.java
package com.daegu.eves.teacher;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Service
public class TeacherService {
	
	 @Autowired
	    private TeacherDao teacherDao;

	 
	    public TeacherVo login(TeacherVo vo) {
	        return teacherDao.login(vo);
	    }
	    
	    public TeacherVo teacherInfo(String tid) {
	    	return teacherDao.teacherInfo(tid);
	    }
	    
	    @Autowired
	       private BCryptPasswordEncoder bCryptPasswordEncoder;

	       public boolean existTid(String tid) {
	           return teacherDao.existTid(tid);
	       }

	       public int insertTeacher(TeacherVo vo) {
	           if (existTid(vo.getTid())) {
	               return -1; // 아이디 중복
	           }
	           // 비밀번호 암호화
	           vo.setTpw(bCryptPasswordEncoder.encode(vo.getTpw()));

	           // 기본값 설정
	           vo.setTchk(0); // 승인 대기
	           vo.setTdate(LocalDate.now().toString());

	           return teacherDao.insertTeacher(vo);
	       }

       // 아이디 중복 체크 기능
       public boolean chkTid(String tid) {
          return teacherDao.existTid(tid);
       }
	    
      
       // 강사 탈퇴
       public int requestDelete(String tid) {
          LocalDateTime now = LocalDateTime.now();
          LocalDateTime due = now.plusDays(30);
          return teacherDao.updateDeleteSchedule(tid, now, due);
       }
       
       // 강사 탈퇴된 상태 로그인 처리 직후
       public void setDeletionDdayToSession(HttpSession session, String tid) {
           LocalDateTime due = teacherDao.findDeleteDueDate(tid); // null 가능
           if (due == null) {
               session.removeAttribute("deleteDday");
               session.removeAttribute("deleteDueDateStr");
               return;
           }
           ZoneId KST = ZoneId.of("Asia/Seoul");
           long days = ChronoUnit.DAYS.between(LocalDate.now(KST), due.toLocalDate());
           long dday = Math.max(0, days);

           session.setAttribute("deleteDday", dday);                       // ex) 17
           session.setAttribute("deleteDueDateStr", due.toLocalDate().toString()); // ex) 2025-12-01
       }
	    
      //admin의 교사정보 불러오기
      public List<TeacherVo> getTeacherList(){
         return teacherDao.getTeacherList();
      }
      // 강사 승인 상태 업데이트
      public void updateApproval(int tno, int status) {
          teacherDao.updateApproval(tno, status);
      }
      
      // 강사 정보 수정
      public TeacherVo getTeacherByTid(String tid) {
	        return teacherDao.findByTid(tid);
	    }

	  public int updateTeacherInfo(TeacherVo teacherVo) {
		  return teacherDao.updateTeacherInfo(teacherVo);
	  }
    
	
//    private final TeacherDao dao;
//    private final PasswordEncoder encoder;
//
//    public TeacherService(TeacherDao dao, PasswordEncoder encoder) {
//        this.dao = dao;
//        this.encoder = encoder;
//    }
//
//    public TeacherVo login(String tid, String rawPw) {
//        TeacherVo t = dao.findByTid(tid);
//        if (t == null) return null;
//        return encoder.matches(rawPw, t.getTpw()) ? t : null;
//    }
}