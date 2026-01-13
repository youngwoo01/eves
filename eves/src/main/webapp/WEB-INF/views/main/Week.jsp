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
 <head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>강의 페이지</title>
  <link rel="stylesheet" href="/eves/resources/css/one.css" />
  <style>
    :root{
      --bg:#fdfcfb;
      --card:#ffffff;
      --border:#e5e7eb;
      --text:#0f172a;
      --muted:#64748b;
      --accent:#3b82f6;     /* 메인 파랑 */
      --accent-dark:#2563eb;
      --comp:#f97316;       /* 보색 오렌지 */
      --comp-light:#fff7ed;
      --radius:14px;
      --shadow:0 14px 28px rgba(0,0,0,.06);
    }
    .enroll .btn {
	  display: inline-block;
	  background: var(--accent);
	  color: #fff;
	  font-weight: 800;
	  padding: 12px 24px;
	  border: none;
	  border-radius: 10px;
	  box-shadow: 0 6px 14px rgba(59,130,246,0.3);
	  cursor: pointer;
	  font-size: 1rem;
	  transition: all 0.2s ease;
	}

	.enroll .btn:hover {
	  background: var(--accent-dark);
	  box-shadow: 0 10px 18px rgba(59,130,246,0.35);
	  transform: translateY(-2px);
	}
	
	.enroll .btn:active {
	  transform: translateY(0);
	  box-shadow: 0 4px 10px rgba(59,130,246,0.25);
	}

    body{
      margin:0;
      background:var(--bg);
      color:var(--text);
      font-family:system-ui,-apple-system,"Noto Sans KR",Roboto,Arial,sans-serif;
      line-height:1.6;
      font-size:1.02rem;
    }

    /* 전체 컨텐츠 래퍼 */
    .container{
      width:100%;
      max-width:none;
      margin:0 auto 56px;
      padding:0 24px;
    }

    /* 상단 정보 카드 */
    .top-card{
      display:grid;
      grid-template-columns:260px 1fr;
      gap:18px;
      background:var(--card);
      border:1px solid var(--border);
      border-radius:var(--radius);
      box-shadow:var(--shadow);
      padding:16px 18px;
      margin:22px 0 16px;
    }

    .thumb{
      width:100%;
      aspect-ratio: 16 / 10;
      border-radius:12px;
      border:1px solid var(--border);
      overflow:hidden;
      background:#f1f5f9;
    }
    .thumb img{
      width:100%;
      height:100%;
      object-fit:cover;
      display:block;
    }

    .info{
      display:flex;
      flex-direction:column;
      gap:10px;
    }

    .title{
      font-size:1.4rem;
      font-weight:800;
      color:var(--accent);
      margin-bottom:2px;
    }

    .meta{
      display:flex;
      flex-wrap:wrap;
      gap:8px;
      color:var(--muted);
      font-weight:700;
    }
    .chip{
      background:#eef2ff;
      color:#374151;
      border:1px solid rgba(59,130,246,.22);
      padding:2px 8px;
      border-radius:999px;
      font-size:.9rem;
    }

    .info-grid{
      display:grid;
      grid-template-columns:repeat(2,minmax(0,1fr));
      gap:10px;
      margin-top:6px;
    }
    .box{
      background:#f8fafc;
      border:1px solid var(--border);
      border-radius:10px;
      padding:10px 12px;
      font-weight:800;
      text-align:center;
    }

    /* 주차 리스트 */
    .lesson-list{
      margin-top:18px;
      display:flex;
      flex-direction:column;
      gap:12px;
    }
    .lesson-item{
      display:flex;
      flex-direction:column;
      background:#fff;
      border:1px solid var(--border);
      border-radius:12px;
      padding:14px 18px;
      box-shadow:var(--shadow);
      transition:transform .12s ease, box-shadow .12s ease;
    }
    .lesson-item:hover{
      transform:translateY(-2px);
      box-shadow:0 18px 30px rgba(0,0,0,.08);
    }
    .lesson-week{
      font-weight:900;
      color:#111827;
      margin-bottom:4px;
    }
    .badge-week{
      display:inline-block;
      background:var(--comp-light);
      color:var(--comp);
      border:1px solid rgba(249,115,22,.3);
      padding:2px 8px;
      border-radius:999px;
      font-size:.85rem;
      font-weight:900;
      margin-right:8px;
    }
    .lesson-title{
      color:#374151;
      font-weight:700;
    }
    .learn-button {
  display: inline-block;
  background: var(--accent);
  color: #fff;
  font-weight: 800;
  padding: 12px 28px;
  border-radius: 10px;
  text-decoration: none;
  box-shadow: 0 6px 14px rgba(59,130,246,0.3);
  font-size: 1.05rem;
  transition: all 0.2s ease;
}

.learn-button:hover {
  background: var(--accent-dark);
  box-shadow: 0 10px 20px rgba(59,130,246,0.35);
  transform: translateY(-2px);
}

.learn-button:active {
  transform: translateY(0);
  box-shadow: 0 4px 10px rgba(59,130,246,0.25);
}
    
    

    /* 반응형 */
    @media (max-width: 860px){
      .top-card{ grid-template-columns:1fr; }
    </style> 
</head>
<body>
  <div class="site-wrap">

    <%@ include file="../include/header.jsp" %>

    <main class="site-main">
      <div class="container">

        <!-- 상단: 썸네일 + 강의 정보 -->
        <section class="top-card">
          <div class="thumb">
            <img src="<c:url value='/image/${lsum}'/>" alt="${lname}" />
          </div>

          <div class="info">
            <div class="title">${lname}</div>

            <div class="meta">
              <span class="chip">분류: ${lcate}</span>
              <span class="chip">레벨: ${llevel}</span>
            </div>

            <div class="grid">
              <div class="box">강의명: ${lname}</div>
              <div class="box">강의분류: ${lcate}</div>
              <div class="box">강의Level: ${llevel}</div>
              <div class="box">학습 준비 완료!</div>
            </div>

            <!-- 로그인으로 이동 유지 -->
            <div class="actions">
              <a href="${pageContext.request.contextPath}/main/Login" class="learn-button">학습하기</a>
            </div>
          </div>
        </section>

        <!-- 레슨(주차) 리스트: 주차 표시는 st.count 사용 -->
        <section class="lesson-list">
          <c:forEach var="wk" items="${lessons}" varStatus="st">
            <div class="lesson-item">
              <div class="lesson-week">
                <span class="badge-week">${st.count}주차</span>
              </div>
              <div class="lesson-title">${wk.wname}</div>
            </div>
          </c:forEach>
        </section>

      </div>
    </main>

    <%@ include file="../include/footer.jsp" %>
  </div>
</body>
</html>
