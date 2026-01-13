// src/main/java/com/daegu/eves/week/WeekController.java
package com.daegu.eves.week;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.daegu.eves.user.UserVo;

@Controller
@RequestMapping("/week")
public class WeekController {

    // 예: /eves/week/play?wno=10&lno=3
    @GetMapping("/play")
    public String play(@RequestParam(name = "wno", required = false) Integer wno,
                       @RequestParam(name = "lno", required = false) Integer lno,
                       HttpServletRequest req,
                       Model model) {
        String ctx = req.getContextPath(); // /eves

        if (wno == null) {
            // wno 없으면 안내 페이지로 돌리거나 기본값 처리
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "wno is required");
        }

        model.addAttribute("wno", wno);
        model.addAttribute("lno", lno);
        model.addAttribute("playUrl",  ctx + "/play/" + wno + "/master.m3u8");
        model.addAttribute("thumbUrl", ctx + "/play/thumbnail/" + wno + "/thumb.jpg");
        return "weeks/Play"; // /WEB-INF/views/weeks/Play.jsp
    }

    /**
     * complete: POST/GET 모두 허용 (호환성 위해)
     * - 폼은 method="post" 그대로 사용 가능
     * - 만약 GET 호출이 들어와도 동일하게 처리하고 redirect로 종료
     */
 // WeekController.java

//    @RequestMapping(value = "/complete-view", method = { RequestMethod.POST, RequestMethod.GET })
//    public String completeLessonView(@RequestParam(name = "wno", required = false) Integer wno,
//                                     @RequestParam(name = "lno", required = false) Integer lno,
//                                     @RequestParam(name = "returnUrl", required = false) String returnUrl,
//                                     HttpSession session,
//                                     RedirectAttributes redirectAttributes,
//                                     HttpServletRequest request) {
//
//        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
//        if (loginUser == null) return "redirect:/Login";
//        int uno = loginUser.getUno();
//
//        if (wno == null) return "redirect:/user/myWeek"; // or 400 처리
//
//        // TODO: 진도 저장 로직
//        // weekService.completeProgress(uno, lno, wno);
//
//        redirectAttributes.addFlashAttribute("msg", "진도 저장 완료!");
//
//        if (returnUrl != null && !returnUrl.isBlank()) return "redirect:" + returnUrl;
//        if (lno != null) return "redirect:/user/myWeek?lno=" + lno;
//
//        String referer = request.getHeader("Referer");
//        if (referer != null && !referer.isEmpty()) return "redirect:" + referer;
//
//        return "redirect:/user/myWeek";
//    }

}
