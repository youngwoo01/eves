<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%
  Integer fqid   = (Integer) request.getAttribute("firstQid");
  String  ftext  = (String)  request.getAttribute("firstText");
  Integer fcount = (Integer) request.getAttribute("firstCount");
  Integer lim    = (Integer) request.getAttribute("limit");

  if (fqid == null)   fqid = 0;
  if (ftext == null)  ftext = "(등록된 문항이 없습니다)";
  if (fcount == null) fcount = 0;
  if (lim == null)    lim = 5;
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>번역 퀴즈</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    :root{
      --bg:#f7faff; --card:#fff; --border:#e5e7eb; --text:#0f172a;
      --muted:#64748b; --accent:#3b82f6; --accent-d:#2563eb;
      --good:#059669; --bad:#dc2626; --radius:14px; --shadow:0 18px 36px rgba(0,0,0,.06);
    }
    *{box-sizing:border-box}
    body{margin:0;background:var(--bg);color:var(--text);font-family:system-ui,-apple-system,"Noto Sans KR",Roboto,Arial,sans-serif}
    .wrap{max-width:760px;margin:28px auto;padding:0 16px}
    .card{background:var(--card);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);padding:20px}
    .title{font-size:1.25rem;font-weight:800;margin-bottom:6px}
    .desc{color:var(--muted);font-weight:600;margin-bottom:16px}
    .qbox{background:#eef2ff;border:1px solid #c7d2fe;border-radius:12px;padding:14px;margin-bottom:16px}
    .qlabel{color:var(--accent);font-weight:800;font-size:.9rem;margin-bottom:6px}
    .qtext{font-size:1.15rem;font-weight:800;line-height:1.5}
    .meta{display:flex;gap:12px;flex-wrap:wrap;color:#475569;font-weight:700;margin:10px 0 16px}
    .meta b{color:#111827}
    textarea{width:100%;min-height:110px;resize:vertical;padding:12px;border:1px solid var(--border);border-radius:10px;font-size:1rem}
    .row{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px}
    .btn{appearance:none;border:0;border-radius:10px;padding:10px 14px;font-weight:800;cursor:pointer}
    .btn.primary{background:var(--accent);color:#fff}
    .btn.secondary{background:#e5e7eb;color:#0f172a}
    .btn:disabled{opacity:.5;cursor:not-allowed}
    .result{border-top:1px solid var(--border);margin-top:16px;padding-top:12px}
    .resline{margin:6px 0}
    .tag{display:inline-block;border-radius:999px;padding:2px 8px;font-size:.85rem;font-weight:800;border:1px solid transparent}
    .tag.good{background:#10b9811a;color:var(--good);border-color:#6ee7b7}
    .tag.bad{background:#fee2e2;color:var(--bad);border-color:#fecaca}
    .right{margin-left:auto}
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <div class="title">번역 퀴즈</div>
      <div class="desc">영어 문장을 보고 한국어로 자연스럽게 번역해 보세요.</div>

      <!-- 문제 -->
      <div class="qbox">
        <div class="qlabel">문제 (영어)</div>
        <div id="qtext" class="qtext"><%= ftext %></div>
      </div>

      <!-- 진행/메타 -->
      <div class="meta">
        <div>문제 ID: <b id="qid"><%= fqid %></b></div>
        <div>진행: <b id="count"><%= fcount %></b>/<b id="limit"><%= lim %></b></div>
      </div>

      <!-- 입력 -->
      <label for="myKo" style="font-weight:800;display:block;margin:6px 0 6px">내 번역 (한국어)</label>
      <textarea id="myKo" placeholder="여기에 번역을 입력하세요. (Shift+Enter 줄바꿈, Enter 제출)"></textarea>

      <div class="row">
        <button id="btnNext" class="btn secondary">다음 문제 ⏭</button>
        <button id="btnCheck" class="btn primary">제출/채점 ✅</button>
        <div class="right"></div>
      </div>

      <!-- 결과 -->
      <div class="result" id="resultBox" style="display:none">
        <div class="resline"><b>정답(참고):</b> <span id="refKo"></span></div>
        <div class="resline"><b>내 번역:</b> <span id="mineKo"></span></div>
        <div class="resline">
          <b>판정/점수:</b>
          <span id="judgeTag" class="tag"></span>
          <span id="scoreText" style="font-weight:800;margin-left:6px"></span>
        </div>
      </div>
    </div>
  </div>

<script>
  const BASE = '${ctx}/quiz-tr';

  const $ = (id) => document.getElementById(id);
  let curQid = parseInt($('qid').innerText || '0', 10) || 0;

  function getCount(){ return parseInt(($('count').innerText||'0').trim(), 10) || 0; }
  function getLimit(){ return parseInt(($('limit').innerText||'5').trim(), 10) || 5; }

  function setFinishedUI() {
    $('qtext').innerText = '퀴즈를 모두 완료했습니다!';
    $('btnNext').disabled = true;
    $('btnCheck').disabled = true;
    $('myKo').disabled = true;

    // 이동 선택 팝업
    setTimeout(() => {
      if (confirm('수고했어요! 진행 현황 그래프로 이동할까요?\n[확인] 진행 그래프 / [취소] 메인으로')) {
        location.href = '${ctx}/quiz/progress';
      } else {
        location.href = '${ctx}/main';
      }
    }, 200);
  }

  async function fetchNext(){
    const cur = getCount(), lim = getLimit();
    if (cur >= lim) { setFinishedUI(); return; }

    try {
      const res = await fetch(BASE + '/next');
      if (!res.ok) throw new Error('HTTP ' + res.status);
      const data = await res.json();

      if (!data.ok) {
        if (data.finished) setFinishedUI();
        else alert('문제를 가져올 수 없습니다.');
        return;
      }

      curQid = data.qid;
      $('qid').innerText   = data.qid;
      $('qtext').innerText = data.text || '';
      $('count').innerText = data.count ?? (cur + 1);

      // 입력 초기화
      $('myKo').value = '';
      $('resultBox').style.display = 'none';
      $('myKo').disabled = false;
      $('btnCheck').disabled = false;

      // 포커스
      $('myKo').focus();

      // 제한 도달 시 버튼 막기
      if (data.count >= lim) {
        $('btnNext').disabled = true;
      }

    } catch (e) {
      console.error(e);
      alert('다음 문제를 불러오지 못했습니다.');
    }
  }

  async function checkAnswer(){
    const cur = getCount();
    const lim = getLimit();
    if (!curQid) { alert('문제를 먼저 불러오세요.'); return; }

    const myKo = ($('myKo').value || '').trim();
    if (!myKo) { alert('번역을 입력하세요.'); $('myKo').focus(); return; }

    try {
      const form = new URLSearchParams();
      form.append('qid', curQid);
      form.append('myKo', myKo);

      const res = await fetch(BASE + '/check', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body: form.toString()
      });
      if (!res.ok) throw new Error('HTTP ' + res.status);

      const data = await res.json();
      if (!data.ok) {
        alert('채점 실패: ' + (data.reason || 'unknown'));
        return;
      }

      // 결과 표시
      $('resultBox').style.display = 'block';
      $('refKo').innerText  = data.ref || '(참고 번역 없음)';
      $('mineKo').innerText = myKo;
      $('scoreText').innerText = (data.score ?? 0) + '점';

      const tag = $('judgeTag');
      tag.className = 'tag ' + (data.correct ? 'good' : 'bad');
      tag.innerText = data.correct ? '정답' : '오답';

      // 입력 잠금
      $('myKo').disabled = true;
      $('btnCheck').disabled = true;

      // 마지막 문제면 다음 버튼 막고 이동 유도
      if (cur >= lim) {
        $('btnNext').disabled = true;
        setFinishedUI();
      }

    } catch (e) {
      console.error(e);
      alert('채점 중 오류가 발생했습니다.');
    }
  }

  // Enter = 제출, Shift+Enter = 줄바꿈
  $('myKo').addEventListener('keydown', (e)=>{
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      $('btnCheck').click();
    }
  });

  $('btnNext').onclick  = fetchNext;
  $('btnCheck').onclick = checkAnswer;

  // 처음 진입 상태: firstQid가 0이면 버튼 비활성
  (function init(){
    const fqid = parseInt('<%= fqid %>', 10) || 0;
    if (!fqid) {
      $('btnCheck').disabled = true;
      $('btnNext').disabled  = false; // 다음 문제로 시작
      $('myKo').disabled     = true;
    } else {
      // firstCount가 0이면 방금 시작한 것으로 보고 count 표시 조정
      const fc = parseInt('<%= fcount %>', 10) || 0;
      $('count').innerText = fc;
    }
  })();
</script>
</body>
</html>
