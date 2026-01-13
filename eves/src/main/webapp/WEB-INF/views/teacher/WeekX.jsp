<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>강의 페이지</title>
    <link rel="stylesheet" href="/eves/resources/css/one.css" />
    <style>
        body { font-family: Arial, sans-serif; }
        .container { width: 600px; margin: 20px auto; border: 1px solid #000; padding: 10px; }
        .top-section { display: flex; gap: 10px; margin-bottom: 10px; }
        .thumbnail { width: 150px; height: 100px; background-color: #ccc; display: flex; align-items: center; justify-content: center; font-weight: bold; }
        .info { flex: 1; display: flex; flex-direction: column; gap: 5px; }
        .info-box { border: 1px solid #000; padding: 8px; background-color: #f9f9f9; border-radius: 4px; text-align: center; font-weight: bold; }
        .learn-button {display: inline-block; background-color: yellow;  /* 버튼 색상 */ padding: 5px 15px; text-align: center; font-weight: bold;
    				   cursor: pointer; border: 1px solid #000; text-decoration: none;/* 링크 밑줄 제거 */ color: black;/* 텍스트 색상 */border-radius: 4px;/* 모서리 둥글게 */}
        .lesson-list { margin-top: 20px; display: flex; flex-direction: column; gap: 5px; }
        .lesson-item { display: flex; border: 1px solid #ccc; padding: 5px; }
        .lesson-week { width: 60px; font-weight: bold; }
        .lesson-title { flex: 1; }
    </style>
</head>
<body>
    <div class="site-wrap">

        <%@ include file="../include/header.jsp" %> 

        <main class="site-main">
            <div class="container">

                <!-- 썸네일 -->
                <div class="top-section">
                    <div class="thumbnail">
                        <img src="<c:url value='/image/${lsum }'/>" style="width:100%; height:100%; object-fit:cover;">
                    </div>

                    <!-- 강의 정보 -->
                    <div class="info">
                    	<div class="info-box">강사: ${tname}</div>
                        <div class="info-box">강의명: ${lname}</div>
                        <div class="info-box">강의분류: ${lcate}</div>
                        <div class="info-box">강의Level: ${llevel}</div>                        
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/teacher/lessonEdit" 
					       class="learn-button">
					       수정하기</a></div>
                </div>
                

                <!-- 레슨 리스트 -->
<!-- 레슨 리스트 -->
<div class="lesson-list">
    <c:forEach var="week" items="${lessons}">
        <div class="lesson-item" style="display: flex; border: 1px solid #ccc; margin-bottom: 10px; border-radius: 5px; overflow: hidden;">

            <!-- 왼쪽 주차 -->
            <div style="width: 80px; font-weight: bold; font-size: 18px; display: flex; align-items: center; justify-content: center; border-right: 1px solid #ccc; padding: 10px 0;">
                ${week.wno}주차
            </div>

            <!-- 오른쪽 내용 (제목 위, 버튼 아래) -->
            <div style="flex: 1; display: flex; flex-direction: column; justify-content: space-between; padding: 10px;">
                <!-- 레슨 제목 -->
                <div style="font-weight: bold; border-bottom: 1px solid #ccc; padding-bottom: 5px;">
                    ${week.wname}
                </div>

                <!-- 다운로드 버튼 -->
                <div style="display: flex; gap: 10px; margin-top: 5px;">
                    <a href="${pageContext.request.contextPath}/download/material/${week.wno}" 
                       class="learn-button" style="flex: 1; text-align: center;">
                        학습자료 다운로드
                    </a>
                    <a href="${pageContext.request.contextPath}/download/video/${week.wno}" 
                       class="learn-button" style="flex: 1; text-align: center;">
                        학습영상 다운로드
                    </a>
                </div>
            </div>

        </div>
        </c:forEach>
       </div>
    
</div>

        </main>

        <%@ include file="../include/footer.jsp" %> 

    </div>
</body>
</html>
