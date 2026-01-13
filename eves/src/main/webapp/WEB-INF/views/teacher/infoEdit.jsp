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

/* 전체 페이지 배경 */
body {
  margin:0;
  background:var(--bg);
  color:var(--text);
  font-family:system-ui,-apple-system,"Noto Sans KR",sans-serif;
}

/* 중앙 정렬 컨테이너 */
.main-container {
  max-width:800px;
  margin:60px auto 100px;
  padding:0 16px;
}

/* 카드형 폼 */
form {
  background:var(--card);
  border:1px solid var(--border);
  border-radius:var(--radius);
  box-shadow:var(--shadow);
  padding:40px 36px;
}

/* 표 기본 스타일 제거 후 정갈하게 */
table {
  width:100%;
  border-collapse:separate;
  border-spacing:0 14px;
}

td {
  border:none;
  padding:10px 12px;
  vertical-align:middle;
}

/* 왼쪽 열(label) */
td:first-child {
  width:180px;
  font-weight:700;
  color:#334155;
  background:#f8fafc;
  border-radius:10px 0 0 10px;
  text-align:center;
  border:1px solid var(--border);
  border-right:none;
}

/* 오른쪽 열(input) */
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

/* 파일 선택 영역 */
input[type="file"] {
  display:block;
  margin-top:8px;
  font-size:.9rem;
  color:#475569;
}

/* 프로필 이미지 */
img {
  border-radius:12px;
  border:1px solid var(--border);
  background:#f1f5f9;
  display:block;
  margin-bottom:8px;
  object-fit:cover;
}

/* 승인여부 텍스트 배지화 */
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

/* 수정하기 버튼 */
button[type="submit"] {
  display:block;
  width:100%;
  margin-top:24px;
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
    width:130px;
    font-size:.9rem;
  }
  form { padding:28px 22px; }
}
</style>
</head>
<body>
  <div class="site-wrap">

    <%@ include file="../include/header.jsp" %> 

    <main class="site-main">
      <div class="main-container">
        <div class="placeholder">
        	
        	<form action="${cp}/teacher/infoEditOk" method="post" enctype="multipart/form-data">
        		<table>
        		<tr>
	        		<td>
					  <img src="${pageContext.request.contextPath}/profile/${teacher.tphoto}" alt="프로필 사진" width="120" height="120">
					  <input type="file" name="proFile">
					</td>
	        		<td><input type="text" name="tdescription" value="${teacher.tdescription }"></td>
        		</tr>
        		
        		<tr>
	        		<td>ID</td>
	        		<td><input type="text" name="tid" value="${teacher.tid }" readonly></td>
        		</tr>
        		
        		<tr>
	        		<td>PW</td>
	        		<td><input type="password" name="tpw" placeholder="새 비밀번호 입력 (변경 시)"> </td>
        		</tr>
        		
        		<tr>
	        		<td>이름</td>
	        		<td><input type="text" name="tname" value="${teacher.tname}"> </td>
        		</tr>
        		
        		<tr>
	        		<td>가입일</td>
	        		<td><input type="date" name="tdate" value="${teacher.tdate }"></td>
        		</tr>
        		
        		<tr>
	        		<td>이메일</td>
	        		<td><input type="email" name="temail" value="${teacher.temail }"></td>
        		</tr>
        		
        		<tr>
	        		<td>승인여부</td>
	        		<td>
				    <c:choose>
				      <c:when test="${teacher.tchk == 1}">
				        승인완료
				      </c:when>
				      <c:otherwise>
				        승인대기
				      </c:otherwise>
				    </c:choose>
  					</td>
        		</tr>
        		</table>
	        	<button type="submit" class="btn">수정하기</button>
        	</form>
        </div>
      </div>
    </main>
    
	<c:if test="${not empty msg}">
		<script>
		  alert("${msg}");
		</script>
	</c:if>

    <%@ include file="../include/footer.jsp" %> 

  </div>
</body>
</html>