// src/main/java/com/daegu/eves/admin/AdminController.java
package com.daegu.eves.admin;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.daegu.eves.lesson.LessonService;
import com.daegu.eves.lesson.LessonVo;
import com.daegu.eves.teacher.TeacherService;
import com.daegu.eves.teacher.TeacherVo;
import com.daegu.eves.user.UserService;
import com.daegu.eves.user.UserVo;
import com.daegu.eves.week.WeekService;
import com.daegu.eves.week.WeekVo;

// ★ 퀴즈 관리 추가
import com.daegu.eves.quiz.QuizDao;
import com.daegu.eves.quiz.QuizVo;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired private TeacherService teacherService;
    @Autowired private UserService userService;
    @Autowired private LessonService lessonService;
    @Autowired private WeekService weekService;

    // admin 로그인 계정(id/pw) 설정값 (예: properties 주입)
    @Autowired private Map<String, String> loginType;

    // ───────────────────────── 공용 유틸 ─────────────────────────
    private boolean isAdmin(HttpSession s) {
        Object t = s.getAttribute("loginType");
        return t != null && "admin".equals(t.toString());
    }

    // ───────────────────────── 기본/인증 ─────────────────────────
    // http://localhost:8090/eves/admin
    @GetMapping({"", "/"})
    public String home() {
        return "admin/home";
    }
    @GetMapping("/home")
    public String home(HttpSession session) {
        // 로그인 체크가 필요하다면 여기에 추가
        // AdminVo admin = (AdminVo) session.getAttribute("loginAdmin");
        // if (admin == null) return "redirect:/admin/Login";
        return "admin/home"; // => /WEB-INF/views/admin/home.jsp
    }

    @GetMapping("/login")
    public String loginForm() {
        return "admin/login";
    }

    @PostMapping("/loginOk")
    public String login(@RequestParam String id,
                        @RequestParam String pw,
                        HttpServletRequest request) {

        if (loginType.get("id").equals(id) && loginType.get("pw").equals(pw)) {
            HttpSession session = request.getSession();
            session.setAttribute("loginType", "admin");
            return "admin/home";
        }
        return "redirect:/admin/login?error=true";
    }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        request.getSession().invalidate();
        return "redirect:/admin/login";
    }

    // ───────────────────────── 사용자/교사 관리 ─────────────────────────
    @GetMapping("/userInfo")
    public String userInfo(Model model, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/admin/login";
        List<UserVo> userList = userService.getUserList();
        model.addAttribute("userList", userList);
        return "admin/userInfo";
    }

    @GetMapping("/teacherInfo")
    public String teacherInfo(Model model, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/admin/login";
        List<TeacherVo> teacherList = teacherService.getTeacherList();
        model.addAttribute("teacherList", teacherList);
        return "admin/teacherInfo";
    }

    // 강사 승인/취소
    @PostMapping("/approve")
    public String approveTeacher(@RequestParam("tno") int tno, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/admin/login";
        teacherService.updateApproval(tno, 1); // 승인
        return "redirect:/admin/teacherInfo";
    }

    @PostMapping("/revoke")
    public String revokeTeacher(@RequestParam("tno") int tno, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/admin/login";
        teacherService.updateApproval(tno, 0); // 승인 대기
        return "redirect:/admin/teacherInfo";
    }

    // ───────────────────────── 퀴즈 관리 ─────────────────────────
    @Autowired private QuizDao quizDao;

    /** 목록 + 등록 폼 (필터: lno/wno 선택) */
    @GetMapping("/quiz")
    public String quizListPage(@RequestParam(required = false) Integer lno,
                               @RequestParam(required = false) Integer wno,
                               HttpSession session,
                               Model model) {
        if (!isAdmin(session)) return "redirect:/admin/login";
        List<QuizVo> list = quizDao.findByLessonWeek(lno, wno);
        model.addAttribute("list", list);
        model.addAttribute("lno", lno);
        model.addAttribute("wno", wno);
        return "admin/quiz/quiz_list_form";
    }

    @PostMapping("/quiz/save")
    public String quizSave(@RequestParam int lno,
                           @RequestParam int wno,
                           @RequestParam String qtext,
                           @RequestParam(required = false) String ktext,  // ✅ 추가
                           HttpSession session) {
        if (!isAdmin(session)) return "redirect:/admin/login";

        QuizVo vo = new QuizVo();
        vo.setLno(lno);
        vo.setWno(wno);
        vo.setQtext(qtext);
        vo.setKtext(emptyToNull(ktext)); // ✅ 빈문자→null 처리(선택)

        quizDao.insertQuiz(vo);
        return "redirect:/admin/quiz?lno=" + lno + "&wno=" + wno;
    }

    /** 수정 폼 */
    @GetMapping("/quiz/edit")
    public String quizEdit(@RequestParam int qid,
                           HttpSession session,
                           Model model) {
        if (!isAdmin(session)) return "redirect:/admin/login";

        QuizVo q = quizDao.findById(qid); // ✅ findById는 ktext 포함 SELECT 필요
        if (q == null) return "redirect:/admin/quiz";

        model.addAttribute("q", q);
        return "admin/quiz/quiz_edit";
    }

    /** 수정 저장 */
    @PostMapping("/quiz/update")
    public String quizUpdate(@RequestParam int qid,
                             @RequestParam int lno,
                             @RequestParam int wno,
                             @RequestParam String qtext,
                             @RequestParam(required = false) String ktext, // ✅ 추가
                             HttpSession session) {
        if (!isAdmin(session)) return "redirect:/admin/login";

        QuizVo vo = new QuizVo();
        vo.setQid(qid);
        vo.setLno(lno);
        vo.setWno(wno);
        vo.setQtext(qtext);
        vo.setKtext(emptyToNull(ktext)); // ✅ 빈문자→null 처리(선택)

        quizDao.updateQuiz(vo);
        return "redirect:/admin/quiz?lno=" + lno + "&wno=" + wno;
    }

    /** 삭제 */
    @PostMapping("/quiz/delete")
    public String quizDelete(@RequestParam int qid,
                             @RequestParam(required = false) Integer lno,
                             @RequestParam(required = false) Integer wno,
                             HttpSession session) {
        if (!isAdmin(session)) return "redirect:/admin/login";
        quizDao.deleteQuiz(qid);

        String redirect = "/admin/quiz";
        if (lno != null) redirect += "?lno=" + lno + (wno != null ? "&wno=" + wno : "");
        return "redirect:" + redirect;
    }

    /** 선택: 공백 문자열을 null로 */
    private String emptyToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
    
    //강사 정보 상세
    @GetMapping("/teacherInfoDetail")
    public String teacherInfoDetail(@RequestParam("tid") String tid, Model model) {
        
        TeacherVo teacher = teacherService.teacherInfo(tid);
        
        if (teacher != null) {
            List<LessonVo> lessonList = lessonService.getLessonListByTno(teacher.getTno(), null, 0, 1000); 

            for (LessonVo lesson : lessonList) {
                List<WeekVo> weeks = weekService.getWeeksListByLno(lesson.getLno());
                lesson.setWeeks(weeks);
            }
            
            model.addAttribute("lessonList", lessonList);
        }

        model.addAttribute("teacher", teacher);
        return "admin/teacherInfoDetail"; 
    }

    // 주차(영상) 삭제
    @PostMapping("/deleteWeek")
    public String deleteWeek(@RequestParam("wno") int wno,
                             @RequestParam("tid") String tid,
                             RedirectAttributes redirectAttributes) {
        
        try {
            weekService.deleteWeekAndFiles(wno);
            
        } catch (Exception e) {
            System.err.println("주차 삭제 중 오류 발생: wno=" + wno + ", " + e.getMessage());
        }
        
        redirectAttributes.addAttribute("tid", tid);
        return "redirect:/admin/teacherInfoDetail";
    }

    // ── (참고) 관리자 주차 페이지가 필요하면 아래처럼 다시 열 수 있음 ──
    // @GetMapping("/teacher/Week")
    // public String adminWeek(@RequestParam("lno") int lno, Model model, HttpSession session) {
    //     if (!isAdmin(session)) return "redirect:/admin/login";
    //     LessonVo lesson = lessonService.getLessonWithTeacher(lno);
    //     List<WeekVo> weeks = weekService.getWeeksByLesson(lno);
    //     model.addAttribute("lname", lesson.getLname());
    //     model.addAttribute("tname", lesson.getTname());
    //     model.addAttribute("lcate", lesson.getLcate());
    //     model.addAttribute("llevel", lesson.getLlevel());
    //     model.addAttribute("lsum", lesson.getLsum());
    //     model.addAttribute("lessons", weeks);
    //     return "admin/teacher/Week";
    // }
}
