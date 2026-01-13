<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 메인</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />

  <style>
    :root {
      --blue: #3b82f6;
      --blue-dark: #2563eb;
      --orange: #f97316;
      --bg1: #e0f2fe;
      --bg2: #fef3c7;
      --text: #0f172a;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: system-ui, -apple-system, "Noto Sans KR", sans-serif;
      background: linear-gradient(135deg, var(--bg1) 0%, var(--bg2) 100%);
      height: 100vh;
      width: 100vw;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      color: var(--text);
      overflow: hidden;
    }

    .site-wrap {
      width: 100%;
      height: 100%;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .main-section {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
    }

    .teacher-nickname {
      font-size: 2.4rem;
      font-weight: 800;
      color: var(--blue-dark);
      margin-bottom: 16px;
    }

    .subtitle {
      font-size: 1.1rem;
      color: #374151;
      margin-bottom: 48px;
    }

    .btn-group {
      display: flex;
      gap: 40px;
      flex-wrap: wrap;
      justify-content: center;
    }

    .btn {
      display: inline-block;
      min-width: 180px;
      padding: 18px 24px;
      border-radius: 14px;
      font-size: 1.1rem;
      font-weight: 700;
      text-decoration: none;
      color: #fff;
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
      transition: all 0.2s ease;
    }

    .btn:hover {
      transform: translateY(-4px);
      box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
    }

    .btn-blue {
      background: var(--blue);
    }

    .btn-orange {
      background: var(--orange);
    }

    footer {
      text-align: center;
      padding: 16px;
      font-size: 0.9rem;
      color: #555;
    }
  </style>
</head>

<body>
  <div class="site-wrap">

    <%@ include file="../include/header.jsp" %> 

    <main class="main-section">
      <div class="teacher-nickname">
        ${tname != null ? tname : '방문자'}님, 환영합니다 👋
      </div>
      <div class="subtitle">아래에서 회원 또는 강사로 시작하세요</div>

      <div class="btn-group">
        <a href="<c:url value='/user/Join'/>" class="btn btn-blue">회원으로 시작하기</a>
        <a href="<c:url value='/teacher/Join'/>" class="btn btn-orange">강사로 시작하기</a>
      </div>
    </main>

    <%@ include file="../include/footer.jsp" %> 
  </div>
</body>
</html>
