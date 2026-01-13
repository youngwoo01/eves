package com.daegu.eves.admin;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.HandlerInterceptor;

public class AdminLoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        HttpSession session = request.getSession(false);

        // 세션이 없거나 로그인하지 않은 경우
        if (session == null || session.getAttribute("loginType") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return false;
        }
        
        // 관리자만 접근 허용
        String loginType = (String) session.getAttribute("loginType");
        if (!"admin".equals(loginType)) {
            response.sendRedirect(request.getContextPath() + "/main"); // 일반 유저는 메인으로 돌려보내기
            return false;
        }

        // 로그인된 경우 정상 진행
        return true;
    }
}
