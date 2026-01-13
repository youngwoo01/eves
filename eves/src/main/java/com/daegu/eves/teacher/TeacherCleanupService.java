package com.daegu.eves.teacher;

import java.util.List;

import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;


// @EnableScheduling로 인해 @Scheduled 실행할 코드
@Service
@RequiredArgsConstructor
public class TeacherCleanupService {

    private final TeacherDao teacherDao;

    // 5초뒤 실행
    @Scheduled(fixedDelay = 5_000)
    @Transactional
    public void scheduledCleanup() {
        System.out.println("[TeacherCleanupService] 정리 작업 시작");

        // 삭제 기한이 지난 강사 목록 조회
        List<String> expired = teacherDao.findExpiredTeachers();

        for (String tid : expired) {
            System.out.println("삭제 대상 강사: " + tid);

            // 강사 계정 삭제
            teacherDao.deleteRelatedData(tid);
        }

        System.out.println("[TeacherCleanupService] 정리 작업 종료");
    }
}
