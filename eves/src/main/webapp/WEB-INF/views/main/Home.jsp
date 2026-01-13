<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 메인</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />

  <style>
    body {
      margin: 0;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Noto Sans KR", sans-serif;
      background: #f9fafb;
      color: #111827;
    }

    .main-container {
      width: 95%;              /* ✅ 폭 넓게 (기존 800px 테이블보다 훨씬 넓음) */
      max-width: 1300px;       /* 화면이 너무 넓을 때 가독성 유지 */
      margin: 24px auto 60px;
    }

    /* 카드 스타일 테이블 */
    .lesson-table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px auto;
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      box-shadow: 0 10px 20px rgba(0,0,0,0.06);
      overflow: hidden;
    }

    .lesson-table td {
      border: none;
      padding: 12px;
    }

    /* 썸네일 */
    .thumb-cell {
      width: 240px;
      background: #f3f4f6;
      text-align: center;
      vertical-align: middle;
    }

    .thumb-cell img {
      width: 220px;
      height: 220px;
      object-fit: cover;
      border-radius: 10px;
      border: 1px solid #e5e7eb;
      background: #fff;
    }

    /* 오른쪽 정보 */
    .info-cell {
      padding: 16px 20px;
      vertical-align: top;
    }

    .title {
      font-size: 1.25rem;
      font-weight: 700;
      margin-bottom: 4px;
    }

    .teacher {
      font-size: 1rem;
      color: #6b7280;
      font-weight: 600;
      margin-bottom: 8px;
    }

    .meta {
      font-size: 0.9rem;
      color: #374151;
      margin-bottom: 12px;
    }

    /* 버튼 */
    .curriculum-btn {
      display: inline-block;
      background: #3b82f6;
      color: #fff;
      font-size: 0.95rem;
      font-weight: 600;
      padding: 10px 18px;
      border-radius: 10px;
      text-decoration: none;
      transition: all 0.15s ease;
      box-shadow: 0 6px 14px rgba(59,130,246,0.25);
    }

    .curriculum-btn:hover {
      filter: brightness(1.07);
      box-shadow: 0 8px 20px rgba(59,130,246,0.3);
      transform: translateY(-1px);
    }

    /* 페이지네이션 */
    .pagination {
      text-align: center;
      margin: 30px 0;
    }

    .pagination a {
      display: inline-block;
      padding: 8px 14px;
      margin: 0 4px;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      color: #111827;
      text-decoration: none;
      background: #fff;
      font-weight: 600;
      transition: all 0.15s ease;
      box-shadow: 0 4px 10px rgba(0,0,0,0.04);
    }

    .pagination a:hover {
      background: #3b82f6;
      color: #fff;
      border-color: #3b82f6;
      box-shadow: 0 8px 18px rgba(59,130,246,0.25);
      transform: translateY(-1px);
    }

    /* 반응형 (모바일에서 세로로) */
    @media (max-width: 820px) {
      .lesson-table {
        display: block;
      }
      .lesson-table tr,
      .lesson-table td {
        display: block;
        width: 100%;
      }
      .thumb-cell {
        border-bottom: 1px solid #e5e7eb;
      }
      .thumb-cell img {
        width: 100%;
        height: auto;
      }
    }
  </style>
</head>
<body>
  <div class="site-wrap">

    <%@ include file="../include/header.jsp" %>
    <%@ include file="../include/nav.jsp" %>

    <main class="site-main">
      <div class="main-container">

        <!-- 강의 리스트 -->
        <c:forEach var="lesson" items="${lessonList}">
          <table class="lesson-table">
            <tr>
              <!-- 썸네일 -->
              <td class="thumb-cell">
                <img src="<c:url value='/image/${lesson.lsum}'/>" alt="${lesson.lname}" />
              </td>

              <!-- 오른쪽 전체 -->
              <td class="info-cell">
                <div class="title">${lesson.lname}</div>
                <div class="teacher">${lesson.tname}</div>
                <div class="meta">
                  분류: ${lesson.lcate} &nbsp;|&nbsp; 레벨: ${lesson.llevel}
                </div>

                <!-- 버튼 -->
                <c:choose>
                  <c:when test="${empty sessionScope.loginType}">
                    <a class="curriculum-btn"
                       href="${pageContext.request.contextPath}/main/Week?lno=${lesson.lno}">
                      커리큘럼 보기 →
                    </a>
                  </c:when>
                  <c:when test="${sessionScope.loginType eq 'user'}">
                    <a class="curriculum-btn"
                       href="${pageContext.request.contextPath}/user/Week?lno=${lesson.lno}">
                      커리큘럼 보기 →
                    </a>
                  </c:when>
                </c:choose>
              </td>
            </tr>
          </table>
        </c:forEach>

        <!-- 검색 / 페이지네이션 -->
        <div class="pagination">
          <c:forEach var="pgn" items="${pageList}">
            <c:choose>
              <c:when test="${not empty keyword}">
                <a href="<c:url value='/main/searchOk'>
                           <c:param name='type' value='${type}'/>
                           <c:param name='keyword' value='${keyword}'/>
                           <c:param name='curPage' value='${pgn.pageNo}'/>
                         </c:url>">
                  ${pgn.display}
                </a>
              </c:when>
              <c:otherwise>
                <a href="<c:url value='/main'>
                           <c:param name='curPage' value='${pgn.pageNo}'/>
                         </c:url>">
                  ${pgn.display}
                </a>
              </c:otherwise>
            </c:choose>
          </c:forEach>
        </div>

      </div>
    </main>

    <%@ include file="../include/footer.jsp" %>
  </div>
</body>
</html>
