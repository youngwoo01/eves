<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>커리큘럼 관리</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/one.css" />
<style>
    .container { width: 80%; margin: 50px auto; }
    .lesson-info { display: flex; justify-content: space-between; align-items: center; gap: 20px; padding: 20px; border: 1px solid #ddd; border-radius: 8px; margin-bottom: 30px; }
    .lesson-info-details { display: flex; align-items: center; gap: 20px; }
    .lesson-info img { width: 200px; height: 120px; object-fit: cover; border-radius: 4px; }
    .info-text h3 { margin-top: 0; }
    .edit-btn { background-color: #ffc107; color: #333; padding: 10px 18px; text-decoration: none; border-radius: 5px; font-weight: bold; white-space: nowrap; }
    .edit-btn:hover { background-color: #e0a800; }
    .weeks-section { display: grid; grid-template-columns: 2fr 1fr; gap: 30px; }
    .weeks-list table { width: 100%; border-collapse: collapse; }
    .weeks-list th, .weeks-list td { border: 1px solid #ddd; padding: 10px; text-align: left; }

    .card{border:1px solid #e5e7eb; border-radius:12px; padding:16px;}
    .title{font-size:18px; font-weight:700; margin-bottom:12px;}
    .row{margin-bottom:16px;}
    label{display:block; margin-bottom:6px; font-weight:600;}
    input[type="number"],input[type="text"]{width:100%; padding:10px; box-sizing:border-box;}
    .drop{border:2px dashed #bbb; border-radius:12px; padding:24px; text-align:center; cursor: pointer;}
    .drop.drag{border-color:#888; background:#fafafa;}
    .actions{display:flex; gap:8px; align-items:center;}
    button[type="submit"] { padding: 10px 15px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
    progress{width:100%; height:16px;}
    .thumb{margin-top:10px; max-width:100%; display:none;}
    .msg{margin-top:10px; font-weight:600;}
</style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/include/header.jsp" />
    <div class="container">
        <h2>커리큘럼 관리 🎬</h2>

        <div class="lesson-info">
            <div class="lesson-info-details">
                <img src="${pageContext.request.contextPath}/image/${lesson.lsum}" alt="${lesson.lname}">
                <div class="info-text">
                    <h3>${lesson.lname}</h3>
                    <p>
                        <c:choose>
                            <c:when test="${lesson.lcate == 'speaking'}">스피킹</c:when>
                            <c:when test="${lesson.lcate == 'voca'}">단어</c:when>
                            <c:when test="${lesson.lcate == 'grammar'}">문법</c:when>
                        </c:choose> | Level ${lesson.llevel}
                    </p>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/teacher/lessonEdit?lno=${lesson.lno}" class="edit-btn">강의 수정</a>
        </div>

        <div class="weeks-section">
            <div class="weeks-list">
                <h4>등록된 주차 목록</h4>
                <table>
                    <thead>
                        <tr>
                            <th>주차 번호</th>
                            <th>주차 이름</th>
                            <th>영상 파일</th>
                        </tr>
                    </thead>
					<tbody>
					  <c:forEach var="week" items="${weeksList}" varStatus="st">
					    <tr>
					      <!-- 🔹 순서대로 1, 2, 3... 출력 -->
					      <td>${st.index + 1}주차</td>
					      <td>${week.wname}</td>
					      <td>${week.wdvideo}</td>
					    </tr>
					  </c:forEach>
					
					  <c:if test="${empty weeksList}">
					    <tr><td colspan="3" style="text-align:center;">등록된 주차가 없습니다.</td></tr>
					  </c:if>
					</tbody>

                </table>
            </div>

            <div class="add-week-container">
                <jsp:include page="/WEB-INF/views/teacher/_weekUploadForm.jsp" />
            </div>

        </div>
    </div>
    
    <jsp:include page="/WEB-INF/views/include/footer.jsp" />
</body>
</html>

