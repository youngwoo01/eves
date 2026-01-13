package com.daegu.eves;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.daegu.eves.lesson.LessonService;
import com.daegu.eves.lesson.LessonVo;
import com.daegu.eves.teacher.TeacherService;
import com.daegu.eves.teacher.TeacherVo;
import com.daegu.eves.user.UserService;
import com.daegu.eves.user.UserVo;
import com.daegu.eves.week.WeekService;
import com.daegu.eves.week.WeekVo;

@Controller
@RequestMapping("/main")
public class MainController {

    @Autowired
    TeacherService teacherService;
    @Autowired
    UserService userService;
    @Autowired
    LessonService lessonService;
    @Autowired
    WeekService weekService;

    // 메인페이지 홈기능
    @GetMapping({"","/"})
    public String home(Model model, PaginationVo pgn) {
        System.out.println("Controller의 home()");

        int curPage = (pgn.getCurPage() > 0) ? pgn.getCurPage() : 1;

        List<LessonVo> lessonList = lessonService.getLessonList(curPage);
        List<PaginationVo> pageList = lessonService.getPagination(curPage);
        model.addAttribute("lessonList", lessonList);
        model.addAttribute("pageList", pageList);

        String next = "main/Home";
        return next;
    }

    // 검색 기능(페이지 유지)
    @GetMapping("/searchOk")
    public String searchLessonOk(PaginationVo pgn,
                                 @RequestParam String type,
                                 @RequestParam String keyword,
                                 Model model) {
        System.out.println("MainController에서 searchLessionOk");

        int curPage = (pgn.getCurPage() > 0) ? pgn.getCurPage() : 1;

        int totalCount = lessonService.countSearchLessons(type, keyword);
        List<PaginationVo> pageList = lessonService.getPagination(curPage, totalCount);
        List<LessonVo> lessons = lessonService.searchLessons(type, keyword, curPage);

        model.addAttribute("lessonList", lessons);
        model.addAttribute("pageList", pageList);
        model.addAttribute("type", type);
        model.addAttribute("keyword", keyword);

        return "main/Home";
    }

    // 로그인 페이지 기능
    @GetMapping("/Login")
    public String login() {
        String next = "main/Login";
        return next;
    }

    // 로그인 완료 기능
    @PostMapping("/LoginOk")
    public String loginOk(@RequestParam("id") String id,
                          @RequestParam("pw") String pw,
                          @RequestParam("userType") String userType,
                          HttpSession session, RedirectAttributes redirectAttributes) {

        String next = "";
        System.out.println("??");

        switch (userType) {
            // 강사로 로그인
            case "teacher":
                TeacherVo teacherVo = new TeacherVo();
                teacherVo.setTid(id);
                teacherVo.setTpw(pw);
                TeacherVo loggedInTeacher = teacherService.login(teacherVo);
                if (loggedInTeacher != null) {
                    if (loggedInTeacher.getTchk() == 1) {
                        session.setAttribute("loginUser", loggedInTeacher);
                        session.setAttribute("loginType", "teacher");
                        teacherService.setDeletionDdayToSession(session, loggedInTeacher.getTid());
                        return "redirect:/main";
                    } else {
                        return "redirect:/main/Login?approval=pending";
                    }
                } else {
                    redirectAttributes.addFlashAttribute("LoginErrMsg", true);
                    return "redirect:/main/Login";
                }

            // 회원으로 로그인
            case "user":
            default:
                UserVo userVo = new UserVo();
                userVo.setUid(id);
                userVo.setUpw(pw);
                UserVo loggedInUser = userService.login(userVo);
                System.out.println("여기까지 와지나?");
                if (loggedInUser != null) {
                    System.out.println("user");

                    // ★ 추가: DAO.login()에서 만료시 uchk=0으로 갱신되어 돌아옴
                    //        만료 안내 플래시 메시지만 추가
                    if (loggedInUser.getUchk() == 0) { // ★ 추가
                        redirectAttributes.addFlashAttribute("msg", "구독이 만료되어 자동 해지되었습니다."); // ★ 추가
                    } // ★ 추가

                    session.setAttribute("loginUser", loggedInUser);
                    session.setAttribute("loginType", "user");
                    next = "redirect:/main";
                } else {
                    redirectAttributes.addFlashAttribute("LoginErrMsg", true);
                    return "redirect:/main/Login";
                }
                break;
        }
        return next;
    }

    // 메인 회원가입 페이지
    @GetMapping("/Join")
    public String joinForm() {
        return "main/Join";
    }

    // 주차 페이지
    @GetMapping("/Week")
    public String week(@RequestParam("lno") int lno, Model model) {
        LessonVo lesson = lessonService.getLesson(lno); // 강의 정보
        List<WeekVo> weeks = weekService.getWeeksByLesson(lno); // 주차 리스트

        model.addAttribute("lname", lesson.getLname());
        model.addAttribute("lcate", lesson.getLcate());
        model.addAttribute("llevel", lesson.getLlevel());
        model.addAttribute("lsum", lesson.getLsum());
        model.addAttribute("lessons", weeks); // JSP에서는 lessons로 주차 리스트 출력

        return "main/Week";
    }
}
