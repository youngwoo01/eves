<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 메인</title>

  <!-- 공통 css -->
  <link rel="stylesheet" href="/eves/resources/css/one.css" />

  <style>
:root {
  --bg-page: #f9fafb;
  --card-bg: #ffffff;
  --card-border: #e5e7eb;
  --text-main: #111827;
  --text-sub: #6b7280;
  --accent: #3b82f6;
  --accent-light: #dbeafe;
  --radius-lg: 14px;
  --radius-md: 10px;
  --shadow-card: 0 14px 28px rgba(0,0,0,0.05);
}

body {
  background: var(--bg-page);
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
  color: var(--text-main);
  line-height: 1.5;
  margin: 0;
  font-size: 1.05rem;
}

.site-wrap {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--bg-page);
}

/* ✅ 메인 컨테이너를 가로 100% 확장 */
.main-container {
  width: 100%;
  max-width: none;
  margin: 0 auto;
  padding: 0 24px; /* 화면 끝에 딱 붙지 않게 살짝 여백 */
}

/* 카드 전체 */
.lesson-card {
  display: grid;
  grid-template-columns: 220px 1fr; /* 썸네일 + 정보 */
  gap: 18px;
  background: var(--card-bg);
  border: 1px solid var(--card-border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-card);
  padding: 16px 20px;
  margin: 14px 0;
  position: relative;
  width: 100%;
}

/* 썸네일 */
.lesson-thumb {
  width: 100%;
  aspect-ratio: 1 / 1;
  background: #f3f4f6;
  border-radius: var(--radius-md);
  border: 1px solid #e5e7eb;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.lesson-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* 오른쪽 정보 */
.lesson-info {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.lesson-top {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.lesson-title {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--text-main);
  line-height: 1.4;
}

.lesson-teacher {
  font-size: 1rem;
  color: var(--text-sub);
  font-weight: 500;
}

.lesson-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 4px;
  font-size: 0.95rem;
  font-weight: 500;
}

.badge {
  background: var(--accent-light);
  color: var(--accent);
  border-radius: var(--radius-md);
  padding: 3px 8px;
  line-height: 1.2;
  border: 1px solid rgba(59,130,246,.2);
}

/* 하단 */
.lesson-bottom {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 12px;
  margin-top: 10px;
}

/* 진도율 */
.progress-wrap {
  flex: 1 1 220px;
}

.progress-label-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--text-sub);
  margin-bottom: 6px;
}

.progress-bar-shell {
  position: relative;
  width: 100%;
  height: 12px;
  background: #e5e7eb;
  border-radius: 999px;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  background: var(--accent);
  border-radius: inherit;
  transition: width .25s ease;
}

.progress-percent-text {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--accent);
  margin-left: 6px;
}

/* 버튼 */
.learn-btn-area {
  flex-shrink: 0;
}

.learn-btn {
  display: inline-block;
  background: var(--accent);
  color: #fff;
  font-size: 1rem;
  font-weight: 700;
  border-radius: var(--radius-md);
  padding: 10px 18px;
  text-decoration: none;
  box-shadow: 0 8px 16px rgba(59,130,246,0.3);
  transition: all .15s ease;
}
.learn-btn:hover {
  filter: brightness(1.07);
  box-shadow: 0 10px 20px rgba(59,130,246,0.4);
  transform: translateY(-1px);
}

/* 페이지네이션 */
.pagination {
  display: flex;
  justify-content: center;
  gap: 6px;
  flex-wrap: wrap;
  margin: 30px 0 40px;
}

.pagination a {
  min-width: 38px;
  height: 38px;
  line-height: 38px;
  text-align: center;
  background: #fff;
  border: 1px solid var(--card-border);
  border-radius: var(--radius-md);
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--text-main);
  text-decoration: none;
  padding: 0 10px;
  box-shadow: 0 6px 14px rgba(0,0,0,0.05);
  transition: all .15s ease;
}
.pagination a:hover {
  background: var(--accent);
  color: #fff;
  border-color: var(--accent);
  box-shadow: 0 10px 20px rgba(59,130,246,0.3);
  transform: translateY(-1px);
}

/* 반응형 */
@media (max-width: 768px) {
  .lesson-card {
    grid-template-columns: 1fr;
    padding: 20px;
  }
  .lesson-thumb {
    max-width: 220px;
    margin: 0 auto;
  }
  .lesson-bottom {
    flex-direction: column;
    align-items: stretch;
  }
  .learn-btn-area {
    text-align: right;
  }
}
  </style>
</head>

<body>
  <!-- 일반 메시지(alert) -->
  <c:if test="${not empty msg}">
    <script>alert("${msg}");</script>
  </c:if>

  <!-- 구독 만료 안내: 반복문 밖에서 한 번만 -->
  <c:if test="${subscribeMsg2}">
    <script>alert("구독권 결제 이후 이용가능한 서비스입니다.");</script>
  </c:if>

  <!-- user 있으면 user.uchk, 없으면 세션에서 -->
  <c:set var="uchk" value="${not empty user ? user.uchk : sessionScope.loginUser.uchk}" />

  <div class="site-wrap">
    <%@ include file="../include/header.jsp" %>
    <%@ include file="../include/nav.jsp" %>

    <main class="site-main">
      <div class="main-container">

        <c:forEach var="lesson" items="${UserLessonList}">
          <div class="lesson-card">

            <div class="lesson-thumb">
              <img src="<c:url value='/image/${lesson.lsum}'/>" alt="${lesson.lname}" />
            </div>

            <div class="lesson-info">
              <div class="lesson-top">
                <div class="lesson-title">${lesson.lname}</div>
                <div class="lesson-teacher">${lesson.tname}</div>
                <div class="lesson-meta">
                  <span class="badge">${lesson.lcate}</span>
                  <span class="badge">레벨: ${lesson.llevel}</span>
                </div>
              </div>

              <div class="lesson-bottom">
                <!-- 진도율 -->
                <div class="progress-wrap">
                  <div class="progress-label-row">
                    <span>학습 진행률</span>
                    <span class="progress-percent-text">${lesson.progress}%</span>
                  </div>
                  <div class="progress-bar-shell">
                    <div class="progress-bar-fill" style="width:${lesson.progress}%;"></div>
                  </div>
                </div>

				<!-- 구독 상태에 따라 버튼 동작 분기 -->
				<div class="learn-btn-area">
				  <c:choose>
				    <c:when test="${uchk == 1 or uchk == '1'}">
				      <a class="learn-btn" href="${cp}/user/myWeek?lno=${lesson.lno}">학습하기 →</a>
				    </c:when>
				    <c:otherwise>
				      <a class="learn-btn" href="javascript:void(0);" onclick="alert('구독권 결제 이후 이용가능한 서비스입니다.');">학습하기 →</a>
				    </c:otherwise>
				  </c:choose>
				</div>
              </div>
            </div>
          </div>
        </c:forEach>

        <!-- 페이지네이션 -->
        <div class="pagination">
          <c:forEach var="pgn" items="${pageList}">
            <c:choose>
              <c:when test="${not empty keyword}">
                <c:url var="searchUrl" value="/user/searchOk">
                  <c:param name="type" value="${type}" />
                  <c:param name="keyword" value="${keyword}" />
                  <c:param name="curPage" value="${pgn.pageNo}" />
                </c:url>
                <a href="${searchUrl}">${pgn.display}</a>
              </c:when>
              <c:otherwise>
                <c:url var="myClassUrl" value="/user/myClass">
                  <c:param name="curPage" value="${pgn.pageNo}" />
                </c:url>
                <a href="${myClassUrl}">${pgn.display}</a>
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
