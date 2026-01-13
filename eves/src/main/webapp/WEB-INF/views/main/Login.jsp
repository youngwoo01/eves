<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>  <!-- 🔹 함수태그 추가 -->
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
<c:if test="${LoginErrMsg}">
<script>
   alert("아이디 혹은 비밀번호가 다릅니다.");
</script>
</c:if>
<meta charset="utf-8" />
<title>로그인</title>
<link rel="stylesheet" href="/eves/resources/css/one.css" />
<style>
  :root {
    --bg: #fdfcfb;
    --card: #ffffff;
    --border: #e5e7eb;
    --text: #0f172a;
    --muted: #64748b;
    --accent: #3b82f6;     /* 메인 블루 */
    --accent-dark: #2563eb;
    --comp: #f97316;       /* 보색 오렌지 */
    --radius: 14px;
    --shadow: 0 14px 28px rgba(0,0,0,.06);
  }

  body {
    margin: 0;
    font-family: system-ui, -apple-system, "Noto Sans KR", sans-serif;
    background: linear-gradient(135deg, #eef2ff 0%, #fdfcfb 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    color: var(--text);
  }

  .login-card {
    width: 100%;
    max-width: 420px;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 32px 28px;
    text-align: center;
  }

  h2 {
    font-size: 1.5rem;
    font-weight: 800;
    color: var(--accent);
    margin-bottom: 24px;
  }

  form {
    display: flex;
    flex-direction: column;
    gap: 16px;
    text-align: left;
  }

  label {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--text);
    margin-bottom: 4px;
    display: block;
  }

  input[type="text"],
  input[type="password"] {
    width: 100%;
    padding: 10px 12px;
    font-size: 0.95rem;
    border: 1px solid var(--border);
    border-radius: 8px;
    background: #f9fafb;
    transition: border-color .15s ease;
  }

  input:focus {
    outline: none;
    border-color: var(--accent);
  }

  hr {
    border: none;
    border-top: 1px solid var(--border);
    margin: 8px 0 16px;
  }

  .user-type {
    display: flex;
    justify-content: space-around;
    font-size: 0.95rem;
    color: var(--muted);
  }

  .user-type label {
    display: flex;
    align-items: center;
    gap: 4px;
    cursor: pointer;
  }

  button[type="submit"] {
    background: var(--accent);
    color: #fff;
    font-size: 1rem;
    font-weight: 700;
    border: none;
    border-radius: 8px;
    padding: 10px 0;
    cursor: pointer;
    box-shadow: 0 8px 16px rgba(59,130,246,0.3);
    transition: all .15s ease;
  }

  button[type="submit"]:hover {
    background: var(--comp);
    box-shadow: 0 10px 20px rgba(249,115,22,0.3);
    transform: translateY(-1px);
  }

  .error-msg {
    color: #dc2626;
    background: #fee2e2;
    border: 1px solid #fecaca;
    padding: 8px 10px;
    border-radius: 8px;
    font-size: 0.9rem;
    margin-top: 12px;
    text-align: center;
  }

  .footer-link {
    margin-top: 16px;
    font-size: 0.9rem;
    color: var(--muted);
    text-align: center;
  }

  .footer-link a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 600;
  }

  .footer-link a:hover {
    color: var(--comp);
  }
</style>
</head>
<body>
  <!-- 🔹 관리자 승인 대기 알림 -->
  <c:if test="${param.approval eq 'pending'}">
     <script>
       alert('관리자 승인 후 로그인 가능합니다.');
     </script>
  </c:if>

  <!-- 🔹 구독 만료 안내 -->
  <c:if test="${not empty msg}">
    <div class="error-msg" role="alert" style="margin-bottom:12px;">
      ${fn:escapeXml(msg)}
    </div>
  </c:if>

  <div class="login-card">
    <h2>로그인</h2>

    <form action="${cp}/main/LoginOk" method="post">
      <div>
        <label for="id">아이디</label>
        <input type="text" id="id" name="id" required />
      </div>

      <div>
        <label for="pw">비밀번호</label>
        <input type="password" id="pw" name="pw" required />
      </div>

      <hr>

      <div class="user-type">
        <label><input type="radio" name="userType" value="user" checked /> 회원</label>
        <label><input type="radio" name="userType" value="teacher" /> 강사</label>
      </div>

      <button type="submit">로그인</button>
    </form>

    <c:if test="${not empty param.error}">
      <div class="error-msg">아이디 또는 비밀번호가 일치하지 않습니다.</div>
    </c:if>

    <div class="footer-link">
      아직 회원이 아니신가요? <a href="${cp}/main/Join">회원가입</a>
    </div>
  </div>
</body>
</html>
