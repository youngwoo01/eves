<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />

  <title>아동용 학습사이트 - 메인</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />
  <style>
:root {
  --bg:#f8fafc;
  --card:#ffffff;
  --border:#e2e8f0;
  --text:#0f172a;
  --muted:#64748b;
  --accent:#2563eb;
  --accent-light:#eff6ff;
  --accent-dark:#1d4ed8;
  --shadow:0 8px 24px rgba(0,0,0,.05);
  --radius:14px;
}

/* 전체 페이지 */
body {
  margin:0;
  background:var(--bg);
  color:var(--text);
  font-family:system-ui,-apple-system,"Noto Sans KR",sans-serif;
}

/* 컨테이너 */
.main-container {
  max-width:1000px;
  margin:50px auto 80px;
  padding:0 16px;
}

/* 표 카드 래퍼 */
.placeholder {
  background:var(--card);
  border:1px solid var(--border);
  border-radius:var(--radius);
  box-shadow:var(--shadow);
  padding:24px 28px;
  overflow-x:auto;
}

/* 표 스타일 */
table {
  width:100%;
  border-collapse:collapse;
  font-size:0.97rem;
  min-width:720px;
}

th, td {
  padding:12px 16px;
  text-align:center;
  border-bottom:1px solid var(--border);
}

th {
  background:var(--accent-light);
  color:var(--accent-dark);
  font-weight:800;
  font-size:1rem;
  border-bottom:2px solid var(--accent);
}

tr:hover {
  background:#f9fbff;
  transition:background 0.2s ease;
}

/* 첫 번째 열(번호) 살짝 강조 */
td:first-child {
  color:var(--accent-dark);
  font-weight:700;
}

/* 구독여부 뱃지 스타일 */
td:nth-child(5) {
  font-weight:700;
}
td:nth-child(5)::before {
  content:"";
  display:inline-block;
  width:10px;
  height:10px;
  border-radius:50%;
  margin-right:6px;
  background:#d1d5db;
  vertical-align:middle;
}
td.status-active::before {
  content: "";
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #22c55e; /* ✅ 구독중은 초록색 */
  margin-right: 6px;
  vertical-align: middle;
}

td.status-inactive::before {
  content: "";
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #94a3b8; /* ✅ 구독안함은 회색 */
  margin-right: 6px;
  vertical-align: middle;
}


/* 카드 hover 효과 */
.placeholder:hover {
  transform:translateY(-2px);
  box-shadow:0 12px 26px rgba(0,0,0,.08);
  transition:all .25s ease;
}

/* 반응형 */
@media (max-width:768px){
  .main-container { margin:30px auto 60px; }
  table { font-size:0.9rem; }
  th, td { padding:10px 12px; }
}
</style>
  
</head>
<body>
  <div class="site-wrap">

   <%@ include file="../include/header.jsp" %> 
   <%@ include file="../include/nav.jsp" %> 
    <main class="site-main">
    	<div class="main-container">
           <div class="placeholder">


        <table>
	        <tr>
	        	<td>번호</td>
	        	<td>ID</td>
	        	<td>이메일</td>
	        	<td>이름</td>
	        	<td>구독여부</td>
	        	<td>구독만료일</td>
	       </tr> 	

       <c:forEach var="userList" items="${userList}" varStatus="status">	        
	        
	        <tr>
        	    <td>${status.count}</td>
	        	<td>${userList.uid}</td>
	        	<td>${userList.uemail}</td>
	        	<td>${userList.uname}</td>
	        	 <%-- ✅ 구독여부 구간 (클래스 동적 지정) --%>
                  <td class="
                    <c:choose>
                      <c:when test='${userList.uchk == 1 or userList.uchk == "1"}'>status-active</c:when>
                      <c:when test='${userList.uchk == 2 or userList.uchk == "2"}'>status-active</c:when>
                      <c:when test='${userList.uchk == 3 or userList.uchk == "3"}'>status-active</c:when>
                      <c:otherwise>status-inactive</c:otherwise>
                    </c:choose>
                  ">
                    <c:choose>
                      <c:when test="${userList.uchk == 1 or userList.uchk == '1'}">1개월</c:when>
                      <c:when test="${userList.uchk == 2 or userList.uchk == '2'}">6개월</c:when>
                      <c:when test="${userList.uchk == 3 or userList.uchk == '3'}">1년</c:when>
                      <c:otherwise>구독안함</c:otherwise>
                    </c:choose>
                  </td>
	         	<td>${userList.send}</td>
	        </tr>
  		</c:forEach>
  		    
        </table>
        
      	</div>
      </div>
    </main>

    <%@ include file="../include/footer.jsp" %> 

  </div>
</body>
</html>
