<%-- /WEB-INF/views/admin/teacherInfoDetail.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <title>강사 상세 정보</title>
  <link rel="stylesheet" href="/eves/resources/css/one.css" />
  <style>
    .detail-table, .lesson-table {
        border-collapse: collapse; width: 80%; margin: 20px auto;
    }
    .detail-table th, .detail-table td, .lesson-table th, .lesson-table td {
        border: 1px solid #ddd; padding: 10px;
    }
    .detail-table th { background-color: #f9f9f9; width: 150px; text-align: right; }
    .lesson-table th { background-color: #f0f0f0; text-align: center; }
    
    .button-container { width: 80%; margin: 20px auto; text-align: right; }
    .delete-btn { background-color: #dc3545; color: white; padding: 5px 10px; border: none; border-radius: 4px; cursor: pointer; font-size: 12px; }
    .delete-btn:hover { background-color: #c82333; }
    
    .week-sub-table { width: 95%; margin: 10px auto; border-collapse: collapse; }
    .week-sub-table th { background-color: #fafafa; padding: 8px; border-bottom: 1px solid #ddd; }
    .week-sub-table td { padding: 8px; border-bottom: 1px solid #eee; }
    .week-sub-table tr:last-child td { border-bottom: none; }
  </style>
</head>
<body>
  <div class="site-wrap">
   <%@ include file="../include/header.jsp" %> 
   <%@ include file="../include/nav.jsp" %> 
   
    <main class="site-main">
    	<div class="main-container">
           <div class="placeholder">
           
            <h2>강사 상세 정보</h2>
            
            <c:if test="${not empty teacher}">
                <table class="detail-table">
                    <tr><th>강사 번호</th><td>${teacher.tno}</td></tr>
                    <tr><th>아이디</th><td>${teacher.tid}</td></tr>
                    <tr><th>이름</th><td>${teacher.tname}</td></tr>
                    <tr><th>이메일</th><td>${teacher.temail}</td></tr>
                    <tr><th>가입일</th><td>${teacher.tdate}</td></tr>
                    <tr><th>승인 상태</th>
                        <td>
                            <c:choose>
                                <c:when test="${teacher.tchk == 1}">승인 완료</c:when>
                                <c:otherwise>승인 대기</c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </table>
                
                <hr style="width: 80%; margin: 30px auto;">
                
                <h2>담당 강의 목록</h2>
                
                <table class="lesson-table">
                    <tr>
                        <th>강의 번호</th>
                        <th>강의명</th>
                        <th>카테고리/레벨</th>
                        <th>주차 정보 (영상)</th>
                    </tr>
                    <c:choose>
                        <c:when test="${not empty lessonList}">
                            <c:forEach var="lesson" items="${lessonList}">
                                <tr>
                                    <td style="text-align: center;">${lesson.lno}</td>
                                    <td>${lesson.lname}</td>
                                    <td style="text-align: center;">${lesson.lcate} / ${lesson.llevel}</td>
                                    
                                    <td>
                                        <c:if test="${not empty lesson.weeks}">
                                            <table class="week-sub-table">
                                                <c:forEach var="week" items="${lesson.weeks}">
                                                    <tr>
                                                        <td>${week.wname} (wno: ${week.wno})</td>
                                                        <td style="width: 80px; text-align: right;">
                                                            <form action="${cp}/admin/deleteWeek" method="POST" onsubmit="return confirm('이 주차를 삭제하시겠습니까?');">
                                                                <input type="hidden" name="wno" value="${week.wno}" />
                                                                <input type="hidden" name="tid" value="${teacher.tid}" />
                                                                <button type="submit" class="delete-btn">주차 삭제</button>
                                                            </form>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </table>
                                        </c:if>
                                        <c:if test="${empty lesson.weeks}">
                                            <p style="font-size: 13px; color: #888; text-align: center; margin: 0;">등록된 주차가 없습니다.</p>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="4" style="text-align: center; padding: 20px;">이 강사가 등록한 강의가 없습니다.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </table>
                
            </c:if>

      	</div>
      </div>
    </main>
    <%@ include file="../include/footer.jsp" %> 
  </div>
</body>
</html>