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
  --accent:#2563eb;      /* 메인 파랑 */
  --accent-dark:#1d4ed8;
  --danger:#dc2626;      /* 승인취소용 빨강 */
  --danger-light:#fee2e2;
  --radius:14px;
  --shadow:0 8px 24px rgba(0,0,0,.05);
}

/* 전체 페이지 배경 및 폰트 */
body {
  margin:0;
  background:var(--bg);
  color:var(--text);
  font-family:system-ui,-apple-system,"Noto Sans KR",sans-serif;
}

/* 메인 컨테이너 */
.main-container {
  max-width:1000px;
  margin:50px auto 80px;
  
}

/* 카드형 표 감싸는 영역 */
.placeholder {
  width:100%;
  background:var(--card);
  border:1px solid var(--border);
  border-radius:var(--radius);
  box-shadow:var(--shadow);
  padding:24px 28px;
  overflow-x:auto;
  transition:box-shadow .2s ease, transform .2s ease;
}
.placeholder:hover {
  box-shadow:0 12px 28px rgba(0,0,0,.08);
  transform:translateY(-1px);
}

/* 표 기본 스타일 */
table {
  width:100%;
  border-collapse:collapse;
  min-width:720px;
  text-align:center;
}

th, td {
  padding:12px 12px;
  border-bottom:1px solid var(--border);
  vertical-align:middle;
}

th {
  background:#eff6ff;
  color:var(--accent-dark);
  font-weight:800;
  font-size:1rem;
  border-bottom:2px solid var(--accent);
}

/* 행 hover */
tr:hover {
  background:#f9fbff;
  transition:background 0.2s ease;
}

/* 버튼 공통 */
button {
  font-family:inherit;
  border:none;
  border-radius:8px;
  padding:8px 14px;
  cursor:pointer;
  font-weight:700;
  transition:all .2s ease;
}

/* 승인 버튼 */
.btn-primary {
  width:90px;
  background:var(--accent);
  color:#fff;
  box-shadow:0 4px 10px rgba(37,99,235,.25);
}
.btn-primary:hover {
  background:var(--accent-dark);
  transform:translateY(-2px);
  box-shadow:0 6px 16px rgba(37,99,235,.35);
}

/* 승인취소 버튼 */
.btn-danger {
  width:90px;
  background:var(--danger-light);
  color:var(--danger);
  border:1px solid #fecaca;
}
.btn-danger:hover {
  background:#fee2e2;
  transform:translateY(-2px);
  box-shadow:0 4px 10px rgba(220,38,38,.2);
}

/* 버튼 크기 조정 */
.btn-sm {
  font-size:.9rem;
  padding:6px 12px;
}

/* 반응형 */
@media (max-width:768px){
  th, td { padding:10px 12px; font-size:.9rem; }
  .btn-sm { padding:6px 10px; }
  .placeholder { padding:20px; }
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
	        	<td>no</td>
	        	<td>ID</td>
	        	<td>이메일</td>
	        	<td>이름</td>
	        	<td>가입일</td>
	        	<td>승인여부</td>
	       </tr> 	

       <c:forEach var="teacherList" items="${teacherList}" varStatus="status">	        
	        
	        <tr>
        	    <td>${status.count}</td>
	        	<td>${teacherList.tid}</td>
	        	<td>${teacherList.temail}</td>
	        	<td>${teacherList.tname}</td>
	        	<td>${teacherList.tdate}</td>
	        	<td>
                   <c:choose>
	                  <c:when test="${teacherList.tchk == 1}">
	                      <form action="${cp}/admin/revoke" method="post" style="display:inline;">
	                         <input type="hidden" name="tno" value="${teacherList.tno}" />
	                         <button type="submit" class="btn btn-sm btn-danger">승인취소</button>
	                       </form>
	                  </c:when>
	                  <c:otherwise>
	                        <form action="${cp}/admin/approve" method="post" style="display:inline;">
	                        <input type="hidden" name="tno" value="${teacherList.tno}" />
	                        <button type="submit" class="btn btn-sm btn-primary">승인하기</button>
	                      </form>
	                  </c:otherwise>
	                </c:choose>
  				</td>
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
