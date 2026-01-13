<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<style>
  .site-header {
    background:#fff;
    border-bottom:1px solid #e5e7eb;
    box-shadow:0 4px 12px rgba(0,0,0,.05);
    position:sticky;
    top:0;
    z-index:1000;
  }

  .header-inner {
    display:grid;
    grid-template-columns: 1fr auto 1fr;
    align-items:center;
    max-width:1200px;
    margin:0 auto;
    padding:10px 16px;
  }

  .header-logo {
    justify-self:center;
    display:flex;
    align-items:center;
    gap:10px;
    text-decoration:none;
    color:#111;
  }
  .header-logo img { height:50px; display:block; }
  .brand { font-weight:800; font-size:1.15rem; letter-spacing:.2px; }

  .nav-right { justify-self:end; }
  .nav-right > ul { display:flex; gap:16px; list-style:none; margin:0; padding:0; }
  .nav-right a {
    text-decoration:none;
    color:#333;
    font-weight:600;
    padding:8px 6px;
    transition:color .2s;
  }
  .nav-right a:hover { color:#2563eb; }

	/* 드롭다운 */
	.dropdown { position: relative; }
	
	/* 기본은 보이지 않게(레이아웃은 block으로 고정) */
	.dropdown .dropdown-content {
	  position: absolute;
	  top: 100%;
	  left: 0;
	  min-width: 170px;
	  margin-top: 4px;
	  padding: 8px 0;
	  background: #fff;
	  border: 1px solid #e5e7eb;
	  border-radius: 8px;
	  box-shadow: 0 8px 20px rgba(0,0,0,0.08);
	  z-index: 999;
	
	  display: block !important;   /* flex로 덮여도 형태 유지 */
	  opacity: 0;                   /* 안 보이게 */
	  visibility: hidden;           /* 포커스/탭도 차단 */
	  pointer-events: none;         /* 클릭 불가 */
	  transform: translateY(6px);
	  transition: opacity .15s ease, transform .15s ease;
	}
	
	/* 보이는 상태(hover/focus-within/JS .open) */
	.dropdown:hover .dropdown-content,
	.dropdown:focus-within .dropdown-content,
	.dropdown.open .dropdown-content {
	  opacity: 1;
	  visibility: visible;
	  pointer-events: auto;
	  transform: translateY(0);
	}
	
	/* 항목들 */
	.dropdown-content li { list-style: none; }
	.dropdown-content a {
	  display: block;
	  padding: 10px 14px;
	  color: #111;
	  white-space: nowrap;
	}
	.dropdown-content a:hover {
	  background: #f3f4f6;
	  color: #2563eb;
	}


  /* 반응형 */
  @media (max-width:768px) {
    .header-inner {
      grid-template-columns: 1fr auto 1fr;
    }
    .nav-right ul {
      gap:12px;
    }
  }
</style>

<header class="site-header" role="banner">
  <div class="header-inner">
    <div class="left-slot"></div>

    <a href="${cp}/main" class="header-logo" aria-label="홈으로">
      <img src="<c:url value='/resources/img/1.png' />" alt="로고" />
      <span class="brand">이브스에옹</span>
    </a>

    <nav class="nav-right" aria-label="주 메뉴">
      <ul>
        <c:choose>
          <c:when test="${empty sessionScope.loginType}">
            <li><a href="${cp}/main/Login">로그인</a></li>
            <li><a href="${cp}/main/Join">회원가입</a></li>
          </c:when>

          <c:when test="${sessionScope.loginType eq 'user'}">
            <li><a href="${cp}/user/buy">구독권</a></li>
            <li><a href="${cp}/user/myClass">내 학습실</a></li>

            <!-- 🟦 드롭다운 (hover 시에만 보임) -->
            <li class="dropdown">
              <a href="#" class="dropbtn">퀴즈 ▾</a>
              <ul class="dropdown-content">
                <li><a href="${cp}/quiz/start">말하기 퀴즈 🎤</a></li>
                <li><a href="${cp}/quiz-tr/start">번역 퀴즈 🌍</a></li>
              </ul>
            </li>

            <li><a href="${cp}/user/info">내 정보</a></li>
            <li><a href="${cp}/user/logout">로그아웃</a></li>
          </c:when>

          <c:when test="${sessionScope.loginType eq 'teacher'}">
            <li><a href="${cp}/teacher/lesson">내 강의실</a></li>
            <li><a href="${cp}/teacher/info">내 정보</a></li>
            <li><a href="${cp}/teacher/logout">로그아웃</a></li>
            
    		<c:if test="${not empty sessionScope.deleteDueDateStr}">
	           <li>
	             <span style="display:inline-block;padding:6px 10px;border-radius:999px;
	                          background:#FEF2F2;border:1px solid #FECACA;color:#991B1B;
	                          font-weight:700;font-size:.85rem;">
	               탈퇴 D-${sessionScope.deleteDday}
	               <small style="opacity:.8;font-weight:600;">(삭제 예정: ${sessionScope.deleteDueDateStr})</small>
	             </span>
	           </li>
            </c:if>
          </c:when>

          <c:when test="${sessionScope.loginType eq 'admin'}">
            <li><a href="${cp}/admin/logout">로그아웃</a></li>
          </c:when>
        </c:choose>
      </ul>
    </nav>
  </div>
</header>
