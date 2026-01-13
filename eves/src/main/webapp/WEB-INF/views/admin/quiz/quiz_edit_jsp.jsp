<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>퀴즈 수정</title>
  <style>
    body{font-family:system-ui, sans-serif; margin:24px; background:#fafafa;}
    .wrap{max-width:740px; margin:0 auto;}
    .card{background:#fff; border:1px solid #eee; border-radius:12px; padding:16px;}
    label{display:block; margin:10px 0 6px; font-weight:600;}
    input[type="number"], textarea{width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;}
    textarea{min-height:120px; resize:vertical;}
    .row{margin-top:16px; display:flex; gap:8px;}
    .btn{padding:8px 14px; border-radius:10px; border:1px solid #ddd; background:#fff; color:#111; text-decoration:none; cursor:pointer;}
    .btn:hover{background:#f6f6f6;}
    .btn.primary{background:#111; color:#fff; border-color:#111;}
  </style>
</head>
<body>
<div class="wrap">
  <h1>퀴즈 수정</h1>
  <div class="card">
    <form method="post" action="${cp}/admin/quiz/update">
      <input type="hidden" name="qid" value="${q.qid}" />

      <label>LNO</label>
      <input type="number" name="lno" value="${q.lno}" required />

      <label>WNO</label>
      <input type="number" name="wno" value="${q.wno}" required />

      <label>문장 (qtext)</label>
      <textarea name="qtext" required>${q.qtext}</textarea>

      <div class="row">
        <button class="btn primary" type="submit">저장</button>
        <a class="btn" href="${cp}/admin/quiz?lno=${q.lno}&wno=${q.wno}">목록</a>
      </div>
    </form>
  </div>
</div>
</body>
</html>
