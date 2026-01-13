<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- 컨텍스트 경로 --%>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<title>login.jsp</title>
<style>
:root {
  --bg:#f1f5f9;
  --card:#ffffff;
  --border:#e2e8f0;
  --text:#0f172a;
  --muted:#64748b;
  --accent:#2563eb;
  --accent-dark:#1e40af;
  --shadow:0 10px 30px rgba(0,0,0,.08);
  --radius:16px;
}

/* 전체화면 정렬 */
body {
  margin:0;
  height:100vh;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
  background:var(--bg);
  font-family:system-ui,-apple-system,"Noto Sans KR",sans-serif;
  color:var(--text);
  overflow:hidden;               /* 스크롤바로 인한 정렬오차 방지 */
}


/* 제목 */
h2 {
  font-size:2rem;
  font-weight:900;
  color:var(--accent);
  margin-bottom:28px;
  text-align:center;
  position:relative;
}

/* 🔒 아이콘 추가 */
h2::before {
  content:"🔒";
  font-size:1.8rem;
  margin-right:10px;
  display:inline-block;
  transform:translateY(2px);
}
h2::after {
  content:"🔒";
  font-size:1.8rem;
  margin-left:10px;
  display:inline-block;
  transform:translateY(2px);
}

/* 카드형 로그인 박스 */
form {
  background:var(--card);
  border:1px solid var(--border);
  border-radius:var(--radius);
  box-shadow:var(--shadow);
  width:100%;
  max-width:400px;
  padding:40px 36px;
  display:flex;
  flex-direction:column;
  gap:18px;
  align-items:center;            /* 입력창 내부도 균등 정렬 */
  box-sizing:border-box;
  margin:0 auto;                 /* 카드 자체를 중앙 정렬 */
}
/* 입력창 */
input[type="text"],
input[type="password"] {
  width:90%;
  padding:14px 16px;
  border:1px solid #cbd5e1;
  border-radius:12px;
  font-size:1rem;
  background:#f8fafc;
  transition:border-color .2s ease, box-shadow .2s ease;
}
input:focus {
  border-color:var(--accent);
  box-shadow:0 0 0 3px rgba(37,99,235,.15);
  outline:none;
}

/* 버튼 */
button[type="submit"] {
  background:var(--accent);
  color:#fff;
  width:90%;
  font-weight:800;
  border:none;
  border-radius:999px;
  padding:14px 0;
  font-size:1rem;
  cursor:pointer;
  transition:all .2s ease;
  box-shadow:0 6px 16px rgba(37,99,235,.25);
}
button[type="submit"]:hover {
  background:var(--accent-dark);
  transform:translateY(-2px);
  box-shadow:0 10px 22px rgba(37,99,235,.35);
}

/* 에러 메시지 */
p[style*="color:red"] {
  margin-top:12px;
  text-align:center;
  color:#dc2626 !important;
  font-weight:600;
}

/* 반응형 */
@media (max-width:480px){
  form { padding:28px 24px; }
  h2 { font-size:1.6rem; }
}
</style>



</head>
<body>
  <div class="container">
    <h2>관리자 로그인</h2>
    

    <form action="${pageContext.request.contextPath}/admin/loginOk" method="post">
      <input type="text" name="id" placeholder="관리자 ID" required>
      <input type="password" name="pw" placeholder="비밀번호" required>
      <button type="submit">로그인</button>
    </form>
  </div>

  <c:if test="${param.error == 'true'}">
    <p style="color:red;">아이디 또는 비밀번호가 올바르지 않습니다.</p>
  </c:if>
</body>
</html>

