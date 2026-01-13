package com.daegu.eves.lesson;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import com.daegu.eves.user.UserVo;

@Controller
@RequestMapping("/lesson")
public class LessonController {

    @Autowired
    private LessonService lessonService;
    // 강의 수정
    
    // 강의 삭제

    // 회원이 수강하기 눌렀을때
    @PostMapping("/enroll")
    public String enrollLesson(@RequestParam("lno") int lno, HttpSession session, RedirectAttributes redirectAttributes) {
        // 로그인 정보 가져오기
        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
        if (loginUser == null) {
            // 로그인 안 되어 있으면 로그인 페이지로 이동
            return "redirect:/Login";
        }

        int uno = loginUser.getUno();

        // 이미 수강 중인지 확인 (중복 등록 방지)
        if (!lessonService.isEnrolled(uno, lno)) {
            lessonService.enrollLesson(uno, lno); // 수강 등록
            System.out.println("새로운 강의 등록 완료: uno=" + uno + ", lno=" + lno);
            redirectAttributes.addFlashAttribute("msg", "새로운 강의가 등록되었습니다!");
        } else {
            System.out.println("이미 등록된 강의입니다.");
            redirectAttributes.addFlashAttribute("msg", "이미 등록된 강의입니다!");
        }

        // 등록 완료 후 내 학습실로 이동
        return "redirect:/user/myClass";
    }
}
