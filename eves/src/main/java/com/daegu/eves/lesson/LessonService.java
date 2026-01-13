package com.daegu.eves.lesson;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.daegu.eves.PaginationVo;
import com.daegu.eves.week.WeekService;
import com.daegu.eves.week.WeekVo;


@Service
public class LessonService {
   
   @Autowired
   LessonDao lessonDao;
   @Autowired
   WeekService weekService;
   
   int listSize=3;         //한 페이지에 표시할 데이터 갯수
   int paginationSize=3;   //한 화면에 표시할 페이지 링크수
   
   //강의 삭제
   public int DeleteLesson(int lno) {
	   return lessonDao.LessonDelete(lno);
   }
   
   // 특정 회원이 특정 강의를 이미 수강 중인지 확인하는 메서드
   public boolean isEnrolled(int uno, int lno) {
       return lessonDao.countEnroll(uno, lno) > 0;
   }
   // 회원이 새 강의를 수강하기 시작할 때 (bridge 테이블에 INSERT)
   public void enrollLesson(int uno, int lno) {
       lessonDao.insertEnroll(uno, lno);
   }
   
   
   public int updateLesson(LessonVo vo) {
       return lessonDao.updateLesson(vo);
   }

   public int getLessonCountByTno(int tno, String keyword) {
       return lessonDao.getLessonCountByTno(tno, keyword);
   }

   public List<LessonVo> getLessonListByTno(int tno, String keyword, int startRecord, int recordSize) {
       return lessonDao.getLessonListByTno(tno, keyword, startRecord, recordSize);
   }

   public LessonVo getLessonByLno(int lno) {
       return lessonDao.getLessonByLno(lno);
   }   

   public int insertLesson(LessonVo vo) {
       return lessonDao.insertLesson(vo);
   }
   
   // 유저 수강강의 불러오기
   public List<LessonVo> getUserLessonList(int uno, int pageNo) {
      int start = (pageNo - 1) * listSize;
      List<LessonVo> lessons = lessonDao.getUserLessonList(uno, start, listSize);

      // 진도율 계산
      for (LessonVo lesson : lessons) {
         int totalWeeks = lessonDao.getTotalWeeks(lesson.getLno());
         int completedWeeks = lessonDao.getCompletedWeeks(uno, lesson.getLno());
        
         int progress = 0;
         if (totalWeeks > 0) {
            progress = (int) Math.round((double) completedWeeks / totalWeeks * 100);
         }
         lesson.setProgress(progress);
      }
      return lessons;
   }
   // 내 학습실의 페이지 기능
   public List<PaginationVo> getUserPagination(int pageNo, int uno) {
      int totalCount = lessonDao.getUserLessonCount(uno);
      return buildPagination(pageNo, totalCount);
   }
   
   
   // 메인페이지 리스트
   public List<LessonVo> getLessonList(int pageNo){
      return lessonDao.getLessonList((pageNo-1)*listSize, listSize);
   }
   
    // 전체 페이지네이션
    public List<PaginationVo> getPagination(int pageNo) {
        int totalCount = lessonDao.getCountBoard();
        return buildPagination(pageNo, totalCount);
    }

    // 검색 결과용 페이지네이션
    public List<PaginationVo> getPagination(int pageNo, int totalCount) {
        return buildPagination(pageNo, totalCount);
    }
    
   
   // 검색 결과 총 개수(보여질 페이지만)
   public int countSearchLessons(String type, String keyword) {
      return lessonDao.countSearchLessons(type, keyword);
   }
   
   // 검색기능
   public List<LessonVo> searchLessons(String type, String keyword, int pageNo) {
       return lessonDao.searchLessons(type, keyword, (pageNo - 1) * listSize, listSize);
   }
   
   // 페이지 기능
    public List<PaginationVo> buildPagination(int pageNo, int totalCount) {
        List<PaginationVo> pageList = new ArrayList<>();

        int numPages = (int) Math.ceil((double) totalCount / listSize);
        int firstLink = ((pageNo - 1) / paginationSize) * paginationSize + 1;
        int lastLink = firstLink + paginationSize - 1;
        if (lastLink > numPages)
            lastLink = numPages;

        if (firstLink > 1) {
            pageList.add(new PaginationVo("<이전", firstLink - 1, pageNo));
        }
        for (int i = firstLink; i <= lastLink; i++) {
            pageList.add(new PaginationVo(String.valueOf(i), i, pageNo));
        }
        if (lastLink < numPages) {
            pageList.add(new PaginationVo("다음>", lastLink + 1, pageNo));
        }

        // 결과가 0건이어도 최소 1페이지 나오도록 설계
        if (pageList.isEmpty()) {
            pageList.add(new PaginationVo("1", 1, 1));
        }

        return pageList;
    }
    
    //주차하지마세요.
    //특정 강의 번호에 해당하는 강의 정보 가져오기
    public LessonVo getLesson(int lno) {
         return lessonDao.getLesson(lno);
     }
    //특정강의 안에 있는 주차별 강의 목록 가져오기
    public List<WeekVo> getLessons(int lno) {
         return lessonDao.getLessons(lno);
     }
    
    //티처조인
    public LessonVo getLessonWithTeacher(int lno) {
        return lessonDao.getLessonWithTeacher(lno);
    }
    public List<LessonVo> getLessonLists(){
    	return lessonDao.getLessonLists();
    }
//    //주차 하지 말라고.
   
    public List<LessonVo> getEnrolledLessonsWithWeeks(int uno) {
		List<LessonVo> lessons = lessonDao.findLessonsByUno(uno);
		for (LessonVo lesson : lessons) {
			List<WeekVo> weeks = weekService.getWeeksListByLno(lesson.getLno());
			lesson.setWeeks(weeks);
		}
		
		return lessons;
	}
    
// // UserController myWeek
//    // 강의와 특정 유저에 대한 상세 정보 반환
//    public LessonVo getLessonDetailForUser(int lno, int uno) {
//        
//        LessonVo lesson = lessonDao.getLessonWithTeacher(lno);
//        if (lesson == null) {
//            return null;
//        }
//
//        List<WeekVo> weeks = weekService.getWeeksListByLno(lno);
//        lesson.setWeeks(weeks);
//
//        int totalWeeks = lessonDao.getTotalWeeks(lno);
//        int completedWeeks = lessonDao.getCompletedWeeks(uno, lno);
//        
//        int progress = 0;
//        if (totalWeeks > 0) {
//            progress = (int) Math.round((double) completedWeeks / totalWeeks * 100);
//        }
//        lesson.setProgress(progress);
//
//        return lesson;
//    }
    
}
