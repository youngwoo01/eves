<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 강사 정보</title>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />
  <style>
    :root{
      --bg:#fdfcfb;
      --card:#ffffff;
      --border:#e5e7eb;
      --text:#0f172a;
      --muted:#64748b;
      --accent:#3b82f6;
      --accent-dark:#2563eb;
      --comp:#f97316;
      --radius:14px;
      --shadow:0 14px 28px rgba(0,0,0,.06);
    }
    body{
      margin:0; background:var(--bg); color:var(--text);
      font-family:system-ui,-apple-system,"Noto Sans KR",sans-serif;
    }
    .main-container{
      width:100%; max-width:1100px; margin:24px auto 48px; padding:0 16px;
    }
    .profile-wrap {
	  display: flex;                 
	  align-items: flex-start;
	  grid-template-columns: 220px 1fr;
	  gap: 24px;background: var(--card);
	  border: 1px solid var(--border);border-radius: var(--radius);
	  box-shadow: var(--shadow); padding: 24px;
	}
	.photo {
	  width: 200px;                
 	  height: auto;                 
	  aspect-ratio: 3/4; border-radius: 12px;overflow: hidden;
	  border: 1px solid var(--border);background: #f1f5f9;
	  display: flex;align-items: center;justify-content: center;
	}
   
    @media (max-width: 860px) {
	  .profile-wrap {
	    grid-template-columns: 1fr;
	    align-items: start;
	  }
	  .photo {
	    max-width: 320px;
	    margin: 0 auto 12px;
	    height:50%
	  }
    .photo img{ width:100%; height:auto; object-fit:cover; display:block; }
    .photo .placeholder{
      color:#94a3b8; font-weight:800; font-size:1rem;
    }

    .info-head{
      display:flex; align-items:center; gap:10px; margin-bottom:8px;
    }
    .name{ font-size:1.5rem; font-weight:900; color:var(--accent); }
    .badge{
      display:inline-block; padding:4px 10px; border-radius:999px;
      font-weight:800; font-size:.85rem; border:1px solid;
    }
    .badge.ok{ background:#ecfeff; color:#0ea5e9; border-color:#a5f3fc; }
    .badge.wait{ background:#fff7ed; color:#f97316; border-color:#fed7aa; }

    .desc{
      color:#334155; background:#f8fafc; border:1px solid var(--border);
      border-radius:10px; padding:12px; line-height:1.6; margin-bottom:12px; min-height:68px;
      white-space:pre-wrap;
    }

    .grid{
      display:grid; grid-template-columns:160px 1fr; gap:10px; align-items:center;
    }
    .label{
      color:#475569; font-weight:800; background:#eef2ff; border:1px solid rgba(59,130,246,.22);
      padding:8px 10px; border-radius:10px; text-align:center;
    }
    .value{
      background:#ffffff; border:1px solid var(--border); border-radius:10px;
      padding:10px 12px; font-weight:700; color:#111827;
    }

    .actions{
      margin-top:18px; display:flex; gap:10px; flex-wrap:wrap; justify-content: flex-end;
    }
    .btn{
      display:inline-block; padding:10px 16px; border-radius:10px; font-weight:800; text-decoration:none;
      transition:.15s ease; border:1px solid transparent;
    }
    .btn-edit{ background:var(--accent); color:#fff; box-shadow:0 8px 16px rgba(59,130,246,.28); }
    .btn-edit:hover{ background:var(--accent-dark); transform:translateY(-1px); }
    .btn-del{ background:#fff; color:#dc2626; border-color:#fecaca; }
    .btn-del:hover{ background:#fee2e2; transform:translateY(-1px); }

    @media (max-width: 860px){
      .profile-wrap{ grid-template-columns:1fr; }
      .photo{ max-width:380px; margin:0 auto; }
    }
  </style>
</head>
<body>
  <div class="site-wrap">
    <%@ include file="../include/header.jsp" %>

    <main class="site-main">
      <div class="main-container">
        <div class="profile-wrap">
          <!-- 사진 -->
          <div class="photo">
            <c:choose>
              <c:when test="${not empty teacher.tphoto}">
               <img src="${pageContext.request.contextPath}/profile/${teacher.tphoto}" alt="프로필 사진">
              </c:when>
              <c:otherwise>
                <div class="placeholder">No Image</div>
              </c:otherwise>
            </c:choose>
          </div>

          <!-- 정보 -->
          <div>
            <div class="info-head">
              <div class="name">${teacher.tname}</div>
              <c:choose>
                <c:when test="${teacher.tchk == 1}">
                  <span class="badge ok">승인완료</span>
                </c:when>
                <c:otherwise>
                  <span class="badge wait">승인대기</span>
                </c:otherwise>
              </c:choose>
            </div>

            <div class="desc">
              <c:out value="${teacher.tdescription}" />
            </div>

            <div class="grid">
              <div class="label">아이디</div>
              <div class="value"><c:out value="${teacher.tid}" /></div>

              <div class="label">비밀번호</div>
              <div class="value">
                <!-- 비밀번호는 절대 원문 표시 금지 -->
                ********
              </div>

              <div class="label">이메일</div>
              <div class="value"><c:out value="${teacher.temail}" /></div>

              <div class="label">가입일</div>
              <div class="value"><c:out value="${teacher.tdate}" /></div>
            </div>

            <div class="actions">
              <a href="<c:url value='/teacher/infoEdit?tid=${teacher.tid}'/>" class="btn btn-edit">정보 수정</a>
              <a href="<c:url value='/teacher/delete'/>" class="btn btn-del"
                 onclick="return confirm('정말 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.');">탈퇴</a>
            </div>
          </div>
        </div>

      </div>
    </main>

    <%@ include file="../include/footer.jsp" %>
  </div>
</body>
</html>
