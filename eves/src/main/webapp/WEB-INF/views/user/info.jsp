<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 내 정보</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />

  <style>
    .page-wrap {
      max-width: 960px;
      margin: 40px auto;
      padding: 16px;
    }

    .profile-card {
      background: #ffffff;
      border-radius: 16px;
      box-shadow: 0 12px 24px rgba(0,0,0,0.08);
      border: 1px solid #eee;
      max-width: 480px;
      margin: 0 auto;
      overflow: hidden;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR", sans-serif;
    }

    .profile-header {
      background: linear-gradient(135deg, #7bd7ff 0%, #a5e9c6 100%);
      padding: 20px 24px;
      color: #003743;
    }

    .profile-header .title {
      font-size: 1rem;
      font-weight: 600;
      opacity: 0.9;
    }

    .profile-header .username {
      font-size: 1.4rem;
      font-weight: 700;
      line-height: 1.3;
      margin-top: 4px;
      color: #003743;
      word-break: break-all;
    }

    .profile-body {
      padding: 20px 24px 8px;
    }

    .info-row {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      padding: 12px 0;
      border-bottom: 1px solid #f2f2f2;
      font-size: 0.95rem;
    }

    .info-label {
      font-weight: 600;
      color: #555;
      min-width: 90px;
    }

    .info-value {
      color: #111;
      text-align: right;
      word-break: break-all;
      max-width: calc(100% - 100px);
      font-weight: 500;
    }

    .pw-dotbox {
      background: #f5f5f7;
      border: 1px solid #dcdce0;
      border-radius: 8px;
      padding: 6px 10px;
      font-weight: 700;
      letter-spacing: 3px;
      font-size: 0.9rem;
      display: inline-block;
      color: #444;
    }

    .badge {
      display: inline-block;
      min-width: 60px;
      text-align: center;
      font-size: 0.8rem;
      font-weight: 600;
      line-height: 1.4;
      border-radius: 999px;
      padding: 4px 10px;
      border: 1px solid transparent;
      white-space: nowrap;
    }

    .badge-sub1 {
      background: #e8fff1;
      color: #0b6b2a;
      border-color: #8dd8a6;
    }

    .badge-sub2 {
      background: #fff8e6;
      color: #7a4b00;
      border-color: #f3d182;
    }

    .badge-none {
      background: #f5f5f7;
      color: #555;
      border-color: #dcdce0;
    }

    .profile-footer {
      padding: 16px 24px 0;
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      flex-wrap: wrap;
    }

    .btn-action {
      appearance: none;
      border: 0;
      text-decoration: none;
      cursor: pointer;
      padding: 10px 14px;
      border-radius: 10px;
      font-size: 0.9rem;
      font-weight: 600;
      line-height: 1.2;
      display: inline-block;
      transition: all 0.15s ease;
    }

    .btn-edit {
      background: #4a6cf7;
      color: #fff;
      box-shadow: 0 6px 14px rgba(74,108,247,0.35);
    }
    .btn-edit:hover {
      box-shadow: 0 8px 18px rgba(74,108,247,0.45);
      transform: translateY(-1px);
    }

    .btn-delete {
      background: #fff1f1;
      color: #b30000;
      border: 1px solid #ffbcbc;
      box-shadow: 0 6px 14px rgba(255,0,0,0.08);
    }
    .btn-delete:hover {
      background: #ffe3e3;
      box-shadow: 0 8px 18px rgba(255,0,0,0.15);
      transform: translateY(-1px);
    }

    /* 리포트 버튼 영역 */
    .report-wrap {
      text-align:center;
      padding:16px 24px 24px;
    }

    .btn-report {
      background: #10b981;
      color: #fff;
      box-shadow: 0 6px 14px rgba(16,185,129,0.35);
    }
    .btn-report:hover {
      box-shadow: 0 8px 18px rgba(16,185,129,0.45);
      transform: translateY(-1px);
    }

    @media (max-width: 480px) {
      .profile-card {
        border-radius: 12px;
      }
      .profile-header {
        padding: 16px 18px;
      }
      .profile-body {
        padding: 16px 18px 4px;
      }
      .profile-footer {
        padding: 16px 18px 0;
      }
      .report-wrap {
        padding:16px 18px 20px;
      }
    }
  </style>
</head>
<body>
<div class="site-wrap">

  <%@ include file="../include/header.jsp" %>

  <main class="site-main">
    <div class="page-wrap">

      <div class="profile-card">

        <!-- 상단: 프로필 헤더 -->
        <div class="profile-header">
          <div class="title">내 정보</div>
          <div class="username">
            <c:out value="${user.uname}" default="이름 없음" /> 님
          </div>
          <div style="font-size:0.8rem; font-weight:500; margin-top:6px; opacity:0.8;">
            계정 ID: <c:out value="${user.uid}" />
          </div>
        </div>

        <!-- 중간: 상세 정보 -->
        <div class="profile-body">

          <div class="info-row">
            <div class="info-label">아이디</div>
            <div class="info-value"><c:out value="${user.uid}" /></div>
          </div>

          <div class="info-row">
            <div class="info-label">비밀번호</div>
            <div class="info-value"><span class="pw-dotbox">******</span></div>
          </div>

          <div class="info-row">
            <div class="info-label">이름</div>
            <div class="info-value"><c:out value="${user.uname}" default="-" /></div>
          </div>

          <div class="info-row">
            <div class="info-label">이메일</div>
            <div class="info-value"><c:out value="${user.uemail}" default="-" /></div>
          </div>

          <div class="info-row">
            <div class="info-label">구독</div>
            <div class="info-value">
              <c:choose>
				  <c:when test="${empty user or empty user.uchk}">
				    <span style="color:gray;">구독안함</span>
				  </c:when>
				
				  <c:when test="${user.uchk == 1}">
				    <span style="color:green;">${dday}</span>
				  </c:when>
				
				  <c:otherwise>
				    <span style="color:gray;">구독안함</span>
				  </c:otherwise>
				</c:choose>
            </div>
          </div>

        </div>

        <!-- 하단: 프로필 수정/삭제 -->
        <div class="profile-footer">
          <a class="btn-action btn-edit"
             href="<c:url value='/user/infoEdit'/>">
            정보 수정
          </a>

          <a class="btn-action btn-delete"
             href="<c:url value='/user/delete'/>"
             onclick="return confirm('정말 탈퇴하시겠습니까?')">
            회원 탈퇴
          </a>
        </div>

        <!-- 퀴즈 점수 리포트 보기 버튼 -->
        <div class="report-wrap">
          <form action="<c:url value='/quiz/progress'/>" method="get" style="display:inline-block; margin:0;">
            <input type="hidden" name="uno" value="${user.uno}" />
            <button type="submit"
                    class="btn-action btn-report"
                    style="min-width:160px;">
              내 퀴즈 성적 보기
            </button>
          </form>
        </div>

      </div>

    </div>
  </main>

  <%@ include file="../include/footer.jsp" %>
</div>
</body>
</html>
