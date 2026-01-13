<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>내 강의 관리</title>
    <link rel="stylesheet" href="/eves/resources/css/one.css" />
    <style>
        .container { width: 80%; margin: 50px auto; }
        
        .title-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .title-bar h2 {
            margin: 0;
        }

        .add-lesson-btn {
            background-color: #007bff;
            color: white;
            padding: 10px 18px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            font-size: 15px;
            transition: background-color 0.2s;
        }
        .add-lesson-btn:hover {
            background-color: #0056b3;
        }

        .search-bar { text-align: center; margin-bottom: 30px; }
        .search-bar input[type="text"] { width: 300px; padding: 8px; }
        .search-bar button { padding: 8px 15px; }
        
        .lesson-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
        .lesson-card { border: 1px solid #ddd; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .lesson-card img { width: 100%; height: 160px; object-fit: cover; }
        .lesson-card-body { padding: 15px; }
        .lesson-card-body h4 a { text-decoration: none; color: #333; }
        .lesson-card-body h4 a:hover { color: #007bff; }
        .lesson-card-tags { margin-top: 10px; }
        .lesson-card-tags span { background-color: #f0f0f0; padding: 3px 8px; border-radius: 4px; font-size: 12px; margin-right: 5px; }

        .pagination { text-align: center; margin-top: 40px; }
        .pagination a, .pagination strong { margin: 0 5px; text-decoration: none; color: #007bff; padding: 5px 10px; border: 1px solid #ddd; }
        .pagination strong { background-color: #007bff; color: white; border-color: #007bff; }
    </style>
</head>
<body>

    <%@ include file="../include/header.jsp" %>

    <div class="container">
        
        <div class="title-bar">
            <h2>내 강의 관리 📚</h2>
            <a href="${pageContext.request.contextPath}/teacher/lessonAdd" class="add-lesson-btn">강의 등록</a>
        </div>

        <div class="search-bar">
            <form action="${pageContext.request.contextPath}/teacher/lesson" method="get">
                <input type="text" name="keyword" placeholder="강의명으로 검색" value="${keyword}">
                <button type="submit">검색</button>
            </form>
        </div>

        <div class="lesson-list">
            <c:choose>
                <c:when test="${not empty lessonList}">
                    <c:forEach var="lesson" items="${lessonList}">
                        <div class="lesson-card">
                            <img src="${pageContext.request.contextPath}/image/${lesson.lsum}" alt="${lesson.lname} 썸네일">
                            <div class="lesson-card-body">
                                <h4>
                                    <a href="${pageContext.request.contextPath}/teacher/week?lno=${lesson.lno}">${lesson.lname}</a>
                                </h4>
                                <div class="lesson-card-tags">
                                    <span>
                                        <c:choose>
                                            <c:when test="${lesson.lcate == 'speaking'}">스피킹</c:when>
                                            <c:when test="${lesson.lcate == 'voca'}">단어</c:when>
                                            <c:when test="${lesson.lcate == 'grammar'}">문법</c:when>
                                            <c:otherwise>${lesson.lcate}</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span>Level ${lesson.llevel}</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p>등록된 강의가 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="pagination">
            <c:if test="${p.prev}">
                <a href="${pageContext.request.contextPath}/teacher/lesson?page=${p.startPage - 1}&keyword=${keyword}">&laquo;</a>
            </c:if>
            <c:forEach var="i" begin="${p.startPage}" end="${p.endPage}">
                <c:choose>
                    <c:when test="${i == p.currentPage}">
                        <strong>${i}</strong>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/teacher/lesson?page=${i}&keyword=${keyword}">${i}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${p.next}">
                <a href="${pageContext.request.contextPath}/teacher/lesson?page=${p.endPage + 1}&keyword=${keyword}">&raquo;</a>
            </c:if>
        </div>
    </div>

    <%@ include file="../include/footer.jsp" %>

</body>
</html>

