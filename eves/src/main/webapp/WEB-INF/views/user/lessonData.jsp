<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>${lesson.lname} - 학습 자료</title>

<style>
:root {
  --accent: #3b82f6;         /* 블루 포인트 */
  --accent-dark: #2563eb;
  --bg-page: #f9fafb;
  --text-main: #111827;
  --text-sub: #6b7280;
  --border: #e5e7eb;
  --radius-md: 8px;          /* 적당한 둥근 정도 */
  --shadow-card: 0 8px 20px rgba(0,0,0,0.05);
}

body {
  font-family: "Pretendard", "Noto Sans KR", sans-serif;
  background: var(--bg-page);
  margin: 0;
  padding: 40px 20px;
  color: var(--text-main);
}

.data-container {
  max-width: 800px;
  margin: 0 auto;
}

h2 {
  text-align: center;
  color: var(--accent);
  font-size: 1.8rem;
  font-weight: 700;
  margin-bottom: 40px;
}

/* PDF 카드 */
.data-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-card);
  padding: 16px 22px;
  margin-bottom: 16px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.data-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 24px rgba(0,0,0,0.08);
}

.data-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--text-main);
  word-break: break-word;
}

/* 다운로드 버튼 */
.data-btn a {
  display: inline-block;
  background: var(--accent);
  color: #fff;
  font-size: 1rem;           /* ✅ 살짝 크게 */
  font-weight: 700;          /* ✅ 굵게 */
  padding: 12px 22px;        /* ✅ 여백 늘림 */
  border-radius: 8px;        /* ✅ 라운드 줄임 */
  box-shadow: 0 4px 10px rgba(59,130,246,0.25);
  text-decoration: none;
  transition: all 0.2s ease;
}
.data-btn a:hover {
  background: var(--accent-dark);
  box-shadow: 0 6px 16px rgba(59,130,246,0.35);
  transform: translateY(-2px);
}

/* 자료 없음 안내 */
p.no-data {
  text-align: center;
  color: var(--text-sub);
  background: #fff;
  border: 1px dashed var(--border);
  border-radius: var(--radius-md);
  padding: 40px 20px;
  box-shadow: var(--shadow-card);
}

/* 돌아가기 버튼 */
.back-btn-wrap {
  text-align: center;
  margin-top: 40px;
}
.back-btn {
  background: var(--accent);
  color: #fff;
  font-size: 1rem;
  font-weight: 700;
  padding: 12px 26px;
  border-radius: 8px;         /* ✅ 동일한 라운드 */
  box-shadow: 0 6px 14px rgba(59,130,246,0.25);
  text-decoration: none;
  transition: all 0.2s ease;
}
.back-btn:hover {
  background: var(--accent-dark);
  box-shadow: 0 10px 22px rgba(59,130,246,0.35);
  transform: translateY(-2px);
}
</style>
</head>

<body>
  <div class="data-container">
    <h2> ${lesson.lname} 강의자료</h2>

    <c:choose>
      <c:when test="${empty pdfList}">
        <p class="no-data">등록된 학습 자료가 없습니다.</p>
      </c:when>

      <c:otherwise>
        <c:forEach var="pdf" items="${pdfList}">
          <div class="data-card">
            <div class="data-title">${pdf.pdpdf}</div>
            <div class="data-btn">
              <a href="${pageContext.request.contextPath}/user/fileDownload?pno=${pdf.pno}">
                 다운로드
              </a>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>

    <!-- ✅ 학습실로 돌아가기 버튼 -->
    <div class="back-btn-wrap">
      <a href="${pageContext.request.contextPath}/user/myWeek?lno=${lesson.lno}" class="back-btn">
        ← 학습실로 돌아가기
      </a>
    </div>
  </div>
</body>
</html>
