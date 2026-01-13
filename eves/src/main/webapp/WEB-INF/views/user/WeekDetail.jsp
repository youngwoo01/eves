<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>주차 상세보기</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />
  <style>
    :root{
      --bg:#fdfcfb;
      --card:#ffffff;
      --border:#e5e7eb;
      --text:#0f172a;
      --muted:#64748b;
      --accent:#3b82f6;       /* 메인 블루 */
      --accent-dark:#2563eb;
      --comp:#f97316;         /* 보색 오렌지 */
      --comp-light:#fff7ed;
      --radius:14px;
      --shadow:0 14px 28px rgba(0,0,0,.06);
    }

    body{
      margin:0;
      background:var(--bg);
      color:var(--text);
      font-family:system-ui,-apple-system,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;
      line-height:1.6;
      font-size:1.05rem;
    }

    /* ✅ 좌우 100% 활용 */
    .detail-wrap{
      width:100%;
      max-width:none;       /* 고정폭 제한 제거 */
      margin:0 auto 48px;   /* 상단은 헤더가 있으니 0, 하단 48 */
      padding:0 24px;       /* 화면 끝에 붙지 않도록 안전 여백 */
    }

    /* 상단 카드형 헤더 */
    .lesson-header{
      background:linear-gradient(180deg,#eff6ff, #ffffff);
      border:1px solid var(--border);
      border-radius:var(--radius);
      box-shadow:var(--shadow);
      padding:18px 20px;
      margin:24px 0 16px;
    }
    .lesson-header h2{
      margin:0 0 6px 0;
      font-size:1.35rem;
      font-weight:800;
      color:var(--accent);
      letter-spacing:.2px;
    }
    .lesson-meta{
      font-size:.95rem;
      color:var(--muted);
      line-height:1.5;
      display:flex;
      gap:10px;
      flex-wrap:wrap;
    }
    .lesson-meta .chip{
      background:#eef2ff;
      color:#374151;
      border:1px solid rgba(59,130,246,.22);
      padding:2px 8px;
      border-radius:999px;
      font-weight:700;
      font-size:.88rem;
    }

    /* 주차 리스트 래퍼 */
    .week-list{
      display:flex;
      flex-direction:column;
      gap:12px;
      margin-top:10px;
    }

    /* 주차 아이템 카드 */
    .week-item{
      display:grid;
      grid-template-columns: 1fr auto;
      align-items:center;
      gap:16px;
      background:var(--card);
      border:1px solid var(--border);
      border-radius:var(--radius);
      box-shadow:var(--shadow);
      padding:14px 18px;
      transition:transform .12s ease, box-shadow .12s ease, background .12s ease;
    }
    .week-item:hover{
      transform:translateY(-2px);
      box-shadow:0 20px 36px rgba(0,0,0,.08);
      background:#fcfdff;
    }

    .week-left{
      display:flex;
      flex-direction:column;
    }
    .week-title{
      font-weight:800;
      font-size:1.02rem;
      color:#111827;
      display:flex;
      align-items:center;
      gap:8px;
    }
    .week-title .num{
      display:inline-block;
      background:var(--comp-light);
      color:var(--comp);
      border:1px solid rgba(249,115,22,.3);
      padding:2px 8px;
      border-radius:999px;
      font-size:.85rem;
      font-weight:800;
    }
    .week-desc{
      font-size:.95rem;
      color:#475569;
      margin-top:4px;
      word-break:keep-all;
    }

    /* 버튼 */
    .week-go a{
      display:inline-block;
      background:var(--accent);
      color:#fff;
      font-weight:800;
      font-size:.98rem;
      padding:10px 16px;
      border-radius:10px;
      text-decoration:none;
      box-shadow:0 10px 18px rgba(59,130,246,.28);
      transition:transform .12s ease, box-shadow .12s ease, background .12s ease;
    }
    .week-go a:hover{
      background:var(--comp); /* 보색으로 전환 */
      box-shadow:0 12px 22px rgba(249,115,22,.35);
      transform:translateY(-2px);
    }

    /* 뒤로가기 */
    .back-area{
      margin:22px 0 8px;
      text-align:center;
    }
    .back-area a{
      font-size:.98rem;
      color:var(--accent-dark);
      text-decoration:underline;
      font-weight:700;
    }
    .back-area a:hover{
      color:var(--comp);
      text-decoration:none;
    }

    /* 반응형 */
    @media (max-width: 840px){
      .week-item{
        grid-template-columns:1fr;
        gap:12px;
      }
      .week-go{ text-align:right; }
    }
  </style>
</head>
<body>
<div class="site-wrap">

  <%@ include file="../include/header.jsp" %>
  <%@ include file="../include/nav.jsp" %>

  <main class="site-main">
    <div class="detail-wrap">

      <!-- 강의 상단 정보 -->
      <div class="lesson-header">
        <h2>${lessonInfo.lname}</h2>
        <div class="lesson-meta">
          <span class="chip">강사: ${lessonInfo.tname}</span>
          <span class="chip">분류: ${lessonInfo.lcate}</span>
          <span class="chip">레벨: ${lessonInfo.llevel}</span>
          <a href="${pageContext.request.contextPath}/user/lessonData?lno=${lessonInfo.lno}"
          style="display:inline-block; background:var(--accent); color:#fff; font-weight:700;
                 padding:8px 14px; border-radius:10px; text-decoration:none;">
         📘 강의자료 보기
         </a>
        </div>
      </div>

      <!-- 주차 리스트 -->
      <div class="week-list">
        <c:forEach var="w" items="${weekList}" varStatus="st">
          <div class="week-item">
            <div class="week-left">
              <div class="week-title">
                <span class="num">${st.index + 1}주차</span>
                <span>학습 콘텐츠</span>
              </div>
              <div class="week-desc">${w.wname}</div>
            </div>
            <div class="week-go">
              <a href="${pageContext.request.contextPath}/week/play?wno=${w.wno}&lno=${w.lno}">
                학습하기 ▶
              </a>
            </div>
          </div>
        </c:forEach>
      </div>

      <div class="back-area">
        <a href="${pageContext.request.contextPath}/user/myClass">← 내 강의 목록으로 돌아가기</a>
      </div>

    </div>
  </main>

  <%@ include file="../include/footer.jsp" %>
</div>
</body>
</html>
