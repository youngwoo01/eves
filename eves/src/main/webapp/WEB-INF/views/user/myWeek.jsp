<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 학습 현황</title>
<link rel="stylesheet" href="/eves/resources/css/one.css" />
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    .container { width: 80%; max-width: 1200px; margin: 50px auto; }
    .lesson-accordion { margin-bottom: 20px; border: 1px solid #ddd; border-radius: 8px; overflow: hidden; }
    .lesson-header { display: flex; align-items: center; gap: 20px; background-color: #f8f9fa; padding: 20px; cursor: pointer; }
    .lesson-header:hover { background-color: #e9ecef; }
    .lesson-header img { width: 180px; height: 108px; object-fit: cover; border-radius: 4px; }
    .lesson-info h3 { margin: 0 0 10px 0; }
    .lesson-info p { margin: 0; color: #6c757d; }
    .lesson-info span { background-color: #e9ecef; padding: 3px 8px; border-radius: 4px; font-size: 13px; margin-right: 8px; }
    .week-list { padding: 10px 20px 20px 20px; background: #fff; display: none; /* Default hidden */ }
    .week-item { display: flex; justify-content: space-between; align-items: center; padding: 15px 0; border-bottom: 1px solid #eee; }
    .week-item:last-child { border-bottom: none; }
    .learn-btn { background-color: #007bff; color: white; padding: 8px 16px; text-decoration: none; border-radius: 5px; transition: background-color 0.2s; }
    .learn-btn:hover { background-color: #0056b3; }
    .empty-message { text-align: center; padding: 50px; color: #6c757d; }
</style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/include/header.jsp" />
    <div class="container">
        <h2>나의 학습 현황 📖</h2>
        <hr><br>
        <c:choose>
            <c:when test="${not empty myLessons}">
                <c:forEach var="lesson" items="${myLessons}">
                    <div class="lesson-accordion">
                        <div class="lesson-header" onclick="toggleWeeks(this)">
                            <img src="${pageContext.request.contextPath}/image/${lesson.lsum}" alt="${lesson.lname} 썸네일">
                            <div class="lesson-info">
                                <h3>${lesson.lname}</h3>
                                <p>
                                    <span>
                                        <c:choose>
                                            <c:when test="${lesson.lcate == 'speaking'}">스피킹</c:when>
                                            <c:when test="${lesson.lcate == 'voca'}">단어</c:when>
                                            <c:when test="${lesson.lcate == 'grammar'}">문법</c:when>
                                        </c:choose>
                                    </span>
                                    <span>Level ${lesson.llevel}</span>
                                    <span>강사: ${lesson.tname}</span>
                                </p>
                            </div>
                        </div>
                        <div class="week-list">
                            <c:forEach var="week" items="${lesson.weeks}">
                                <div class="week-item">
                                    <span>${week.wname}</span>
                                    <a href="#" class="learn-btn">학습하기</a>
                                </div>
                            </c:forEach>
                            <c:if test="${empty lesson.weeks}">
                                <p style="text-align: center; color: #888; padding: 20px 0;">아직 등록된 주차가 없습니다.</p>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p class="empty-message">수강 중인 강의가 없습니다.</p>
            </c:otherwise>
        </c:choose>
    </div>

    <script>
        function toggleWeeks(headerElement) {
            // 클릭된 헤더 다음에 오는 week-list 요소를 찾습니다.
            const weekList = headerElement.nextElementSibling;
            if (weekList.style.display === "block") {
                weekList.style.display = "none";
            } else {
                weekList.style.display = "block";
            }
        }
    </script>

    <jsp:include page="/WEB-INF/views/include/footer.jsp" />
</body>
</html>
