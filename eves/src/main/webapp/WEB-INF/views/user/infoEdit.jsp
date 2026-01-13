<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 컨텍스트 경로 --%>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 메인</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />
<style>
:root {
  --bg:#f9fafb;
  --card:#ffffff;
  --border:#e5e7eb;
  --text:#0f172a;
  --muted:#64748b;
  --accent:#3b82f6;
  --accent-dark:#2563eb;
  --radius:14px;
  --shadow:0 10px 28px rgba(0,0,0,.05);
}

body {
  margin:0;
  background:var(--bg);
  color:var(--text);
  font-family:system-ui,-apple-system,"Noto Sans KR",sans-serif;
  line-height:1.6;
}

.main-container {
  max-width:800px;
  margin:60px auto 100px;
  padding:0 16px;
}

/* 폼 카드 전체 */
form {
  background:var(--card);
  border:1px solid var(--border);
  border-radius:var(--radius);
  box-shadow:var(--shadow);
  padding:36px 32px;
  transition:box-shadow .2s ease, transform .2s ease;
}
form:hover {
  box-shadow:0 12px 28px rgba(0,0,0,.08);
  transform:translateY(-2px);
}

/* 표 꾸미기 */
table {
  width:100%;
  border-collapse:separate;
  border-spacing:0 14px; /* 행 사이 간격 */
}

td {
  padding:14px 16px;
  vertical-align:middle;
  background:#fff;
  border:none;
}

/* 왼쪽 제목 셀 */
td:first-child {
  width:150px;
  font-weight:700;
  color:#334155;
  background:#f8fafc;
  text-align:center;
  border:1px solid var(--border);
  border-right:none;
  border-radius:10px 0 0 10px;
  box-shadow:inset 0 0 0 1px rgba(0,0,0,0.02);
}

/* 오른쪽 입력 셀 */
td:nth-child(2) {
  border:1px solid var(--border);
  border-left:none;
  border-radius:0 10px 10px 0;
  background:#ffffff;
}

/* 입력창 스타일 */
input[type="text"],
input[type="password"],
input[type="email"],
input[type="date"],
textarea {
  width:100%;
  padding:12px 14px;
  border:1px solid #d1d5db;
  border-radius:10px;
  font-size:1rem;
  background:#f9fafb;
  transition:border-color .2s ease, box-shadow .2s ease, background .2s ease;
}
input:focus, textarea:focus {
  border-color:var(--accent);
  background:#fff;
  box-shadow:0 0 0 3px rgba(59,130,246,.12);
  outline:none;
}

/* 파일 선택 */
input[type="file"] {
  display:block;
  margin-top:6px;
  font-size:.9rem;
  color:#475569;
}

/* 프로필 이미지 */
img {
  border-radius:10px;
  border:1px solid var(--border);
  margin-bottom:6px;
  background:#f1f5f9;
  display:block;
}

/* 승인 여부 텍스트 */
td:nth-child(2):has(.status) {
  text-align:left;
}
.status {
  display:inline-block;
  padding:6px 14px;
  border-radius:999px;
  font-weight:700;
  font-size:.9rem;
}
.status.ok {
  background:#e0f2fe;
  color:#0369a1;
}
.status.wait {
  background:#fff7ed;
  color:#f97316;
}

/* 수정 버튼 */
button[type="submit"] {
  display:block;
  width:100%;
  margin-top:26px;
  background:var(--accent);
  color:#fff;
  font-weight:800;
  border:none;
  border-radius:999px;
  padding:14px 0;
  font-size:1.05rem;
  cursor:pointer;
  box-shadow:0 6px 16px rgba(59,130,246,.25);
  transition:all .2s ease;
}
button[type="submit"]:hover {
  background:var(--accent-dark);
  transform:translateY(-2px);
  box-shadow:0 10px 22px rgba(59,130,246,.35);
}
button[type="submit"]:active {
  transform:translateY(0);
  box-shadow:0 3px 8px rgba(59,130,246,.2);
}

/* 반응형 */
@media (max-width:768px){
  td:first-child {
    width:120px;
    font-size:.9rem;
  }
  form {
    padding:26px 20px;
  }
}
</style>

</head>
<body>
  <div class="site-wrap">

    <%@ include file="../include/header.jsp" %> 

    <main class="site-main">
      <div class="main-container">
        <div class="placeholder">
        	
        	<form action="${cp}/user/infoEdit" method="post">
        		<table border=1>
        		
        		<tr>
	        		<td>ID</td>
	        		<td><input type="text" name="uid" value="${user.uid }" readonly ></td>
        		</tr>
        		
        		<tr>
	        		<td>PW</td>
	        		<td><input type="text" value="******" readonly></td>
        		</tr>
        		
        		<tr>
	        		<td>이름</td>
	        		<td><input type="text" name="uname" value="${user.uname}"> </td>
        		</tr>
        		
        		<tr>
	        		<td>이메일</td>
	        		<td><input type="email" name="uemail" value="${user.uemail }"></td>
        		</tr>
        		
        		<tr>
	        		<td>구독여부</td>
	        		<td>
				    <c:choose>
				      <c:when test="${user.uchk == 1}">
				        구독중
				      </c:when>
				      <c:otherwise>
				        구독안함
				      </c:otherwise>
				    </c:choose>
  					</td>
        		</tr>
        		</table>
        	    <button type="submit" onclick="return confirm('수정하시겠습니까?')">수정</button>
        	</form>
        </div>
      </div>
    </main>

    <%@ include file="../include/footer.jsp" %> 

  </div>
</body>
</html>