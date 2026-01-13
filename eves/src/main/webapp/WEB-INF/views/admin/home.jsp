<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>관리자 홈</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />

  <style>
    :root {
      --accent: #3b82f6;
      --accent-dark: #2563eb;
      --bg-page: #f9fafb;
      --card-bg: #ffffff;
      --border: #e5e7eb;
      --text-main: #111827;
      --radius-lg: 14px;
      --shadow-card: 0 8px 20px rgba(0,0,0,0.05);
    }

    body {
      font-family: 'Pretendard', 'Noto Sans KR', sans-serif;
      background: var(--bg-page);
      margin: 0;
      color: var(--text-main);
    }

    main.site-main {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 80vh;
    }

    .main-container {
      width: 100%;
      max-width: 700px;
      padding: 40px 20px;
    }

    .placeholder {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      box-shadow: var(--shadow-card);
      padding: 60px 40px;
      text-align: center;
      animation: fadein 0.4s ease;
    }

    @keyframes fadein {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .placeholder h2 {
      font-size: 1.8rem;
      font-weight: 700;
      color: var(--accent);
      margin-bottom: 36px;
    }

    .placeholder div {
      display: flex;
      justify-content: center;
      flex-wrap: wrap;
      gap: 20px;
    }

    .btn {
      display: inline-block;
      background: var(--accent);
      color: #fff;
      padding: 16px 32px;
      border-radius: 10px;
      font-size: 1.1rem;
      font-weight: 700;
      text-decoration: none;
      box-shadow: 0 6px 14px rgba(59,130,246,0.25);
      transition: all 0.2s ease;
    }
    .btn:hover {
      background: var(--accent-dark);
      box-shadow: 0 10px 20px rgba(59,130,246,0.35);
      transform: translateY(-2px);
    }
  </style>
</head>

<body>
  <div class="site-wrap">
    <%@ include file="../include/header.jsp" %> 
    <main class="site-main">
      <div class="main-container">
        <div class="placeholder">
          <h2>관리자 홈</h2>
          <div>
            <a href="<c:url value='/admin/userInfo'/>" class="btn">회원 정보</a>
            <a href="<c:url value='/admin/teacherInfo'/>" class="btn">강사 관리</a>
            <a href="<c:url value='/admin/quiz'/>" class="btn">퀴즈 등록</a>
          </div>
        </div>
      </div>
    </main>
    <%@ include file="../include/footer.jsp" %> 
  </div>
</body>
</html>
