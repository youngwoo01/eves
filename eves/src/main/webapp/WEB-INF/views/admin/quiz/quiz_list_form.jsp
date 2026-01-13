<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>관리자 - 퀴즈 관리</title>
  <style>
    body{font-family:system-ui, sans-serif; margin:24px; background:#fafafa;}
    .wrap{max-width:1100px; margin:0 auto;}
    h1{margin:0 0 16px;}
    .grid{display:grid; grid-template-columns: 1fr 2fr; gap:20px;}
    .card{background:#fff; border:1px solid #eee; border-radius:12px; padding:16px;}
    label{display:block; margin:10px 0 6px; font-weight:600;}
    input[type="number"], input[type="text"], textarea{width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;}
    textarea{min-height:110px; resize:vertical;}
    .row{margin:16px 0;}
    .btn{display:inline-block; padding:8px 14px; border-radius:10px; text-decoration:none; border:1px solid #ddd; background:#fff; color:#111; cursor:pointer;}
    .btn:hover{background:#f6f6f6;}
    .btn.primary{background:#111; color:#fff; border-color:#111;}
    table{width:100%; border-collapse:collapse;}
    th, td{border-bottom:1px solid #eee; padding:10px; text-align:left; vertical-align:top;}
    .actions{display:flex; gap:6px; flex-wrap:wrap;}
    .filters{display:flex; gap:8px; align-items:flex-end;}
    .filters input{width:120px;}
    .muted{color:#666; font-size:13px;}
    details{margin-top:6px;}
    details summary{cursor:pointer; user-select:none; font-size:13px; color:#333;}
    .row-inline{display:grid; grid-template-columns: repeat(2, 1fr); gap:10px;}
    .nowrap{white-space:pre-wrap;}
    /* ✅ 상단 버튼 라인 */
    .top-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }
    .top-bar h1 {
      margin: 0;
    }
  </style>
</head>
<body>
<div class="wrap">

  <!-- ✅ 상단 타이틀 + 돌아가기 버튼 -->
  <div class="top-bar">
    <h1>퀴즈 관리</h1>
    <a href="${cp}/admin/home" class="btn">← 관리자 홈으로 돌아가기</a>
  </div>

  <!-- 필터 -->
  <form class="card filters" method="get" action="${cp}/admin/quiz">
    <div>
      <label>LNO (강의 번호)</label>
      <input type="number" name="lno" value="${lno}" min="1" />
    </div>
    <div>
      <label>WNO (주차 번호)</label>
      <input type="number" name="wno" value="${wno}" min="1" />
    </div>
    <div>
      <button class="btn">필터 적용</button>
      <a class="btn" href="${cp}/admin/quiz">초기화</a>
    </div>
  </form>

  <div class="grid">

    <!-- 등록 폼 -->
    <div class="card">
      <h2>퀴즈 등록</h2>
      <form method="post" action="${cp}/admin/quiz/save">
        <label>LNO</label>
        <input type="number" name="lno" value="${lno}" min="1" required />

        <label>WNO</label>
        <input type="number" name="wno" value="${wno}" min="1" required />

        <label>문장 (qtext)</label>
        <textarea name="qtext" placeholder="예) hello my name is ..." required></textarea>

        <!-- ✅ 신규: KTEXT 추가 -->
        <label>해석/정답 (ktext)</label>
        <textarea name="ktext" placeholder="예) 안녕하세요, 제 이름은 ... 입니다."></textarea>

        <div class="row">
          <button class="btn primary" type="submit">등록</button>
        </div>
        <p class="muted">* 등록 후 리스트 상단에 최신순으로 표시됩니다.</p>
      </form>
    </div>

    <!-- 리스트 -->
    <div class="card">
      <h2>퀴즈 목록</h2>
      <table>
        <thead>
          <tr>
            <th style="width:70px;">QID</th>
            <th style="width:80px;">LNO</th>
            <th style="width:80px;">WNO</th>
            <th>QTEXT</th>
            <th>KTEXT</th>
            <th style="width:200px;">관리</th>
          </tr>
        </thead>
        <tbody>
        <c:forEach var="q" items="${list}">
          <tr>
            <td>${q.qid}</td>
            <td>${q.lno}</td>
            <td>${q.wno}</td>
            <td class="nowrap">${q.qtext}</td>
            <!-- ✅ 목록에 KTEXT 표시 -->
            <td class="nowrap"><c:out value="${q.ktext}" /></td>
            <td>
              <div class="actions">
                <!-- ✅ 인라인 수정 토글 -->
                <details>
                  <summary>수정</summary>
                  <form method="post" action="${cp}/admin/quiz/update" style="margin-top:8px;">
                    <input type="hidden" name="qid" value="${q.qid}" />
                    <!-- 필터 유지용 -->
                    <input type="hidden" name="lnoFilter" value="${lno}" />
                    <input type="hidden" name="wnoFilter" value="${wno}" />

                    <div class="row-inline">
                      <div>
                        <label>LNO</label>
                        <input type="number" name="lno" value="${q.lno}" min="1" required />
                      </div>
                      <div>
                        <label>WNO</label>
                        <input type="number" name="wno" value="${q.wno}" min="1" required />
                      </div>
                    </div>

                    <label>문장 (qtext)</label>
                    <textarea name="qtext" required>${q.qtext}</textarea>

                    <!-- ✅ 인라인 수정에서 KTEXT도 편집 -->
                    <label>해석/정답 (ktext)</label>
                    <textarea name="ktext"><c:out value="${q.ktext}"/></textarea>

                    <div class="row">
                      <button class="btn primary" type="submit">저장</button>
                    </div>
                  </form>
                </details>

                <!-- 삭제 -->
                <form method="post" action="${cp}/admin/quiz/delete" onsubmit="return confirm('삭제할까요?');">
                  <input type="hidden" name="qid" value="${q.qid}" />
                  <input type="hidden" name="lno" value="${lno}" />
                  <input type="hidden" name="wno" value="${wno}" />
                  <button class="btn" type="submit">삭제</button>
                </form>

              </div>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty list}">
          <tr><td colspan="6" class="muted">데이터가 없습니다.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>

  </div>
</div>
</body>
</html>
