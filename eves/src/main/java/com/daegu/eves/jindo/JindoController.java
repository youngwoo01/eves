// src/main/java/com/daegu/eves/jindo/JindoController.java
package com.daegu.eves.jindo;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.daegu.eves.user.UserVo;

@Controller
@RequestMapping("/week")
public class JindoController {

    private final JindoService jindoService;

    public JindoController(JindoService jindoService) {
        this.jindoService = jindoService;
    }

    @PostMapping("/complete")
    public String complete(HttpSession session,
                           @RequestParam int wno,
                           @RequestParam int lno, // ★ 필수로 변경
                           @RequestParam(required = false) String returnUrl,
                           RedirectAttributes ra,
                           HttpServletRequest request) {

        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/Login";
        }
        int uno = loginUser.getUno();

        int affected;
        try {
            affected = jindoService.markComplete(uno, lno, wno);
        } catch (Exception e) {
            e.printStackTrace();
            ra.addFlashAttribute("msg", "진도 저장 중 오류가 발생했습니다.");
            return decideRedirect(returnUrl, lno, request);
        }

        if (affected == 1) {
            ra.addFlashAttribute("msg", "진도 저장 완료!");
        } else if (affected == 2) {
            ra.addFlashAttribute("msg", "이미 저장된 진도를 갱신했습니다.");
        } else {
            ra.addFlashAttribute("msg", "이미 최신 진도입니다.");
        }

        return decideRedirect(returnUrl, lno, request);
    }

    private String decideRedirect(String returnUrl, Integer lno, HttpServletRequest request) {
        if (returnUrl != null && !returnUrl.isBlank()) {
            return "redirect:" + returnUrl;
        }
        if (lno != null) {
            return "redirect:/user/myWeek?lno=" + lno;
        }
        String ref = request.getHeader("Referer");
        if (ref != null && !ref.isEmpty()) {
            return "redirect:" + ref;
        }
        return "redirect:/user/myWeek";
    }
}
