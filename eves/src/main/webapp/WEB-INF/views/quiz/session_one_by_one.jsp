<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String firstText   = (String) request.getAttribute("firstText");
    Integer firstQid   = (Integer) request.getAttribute("firstQid");
    Integer firstCount = (Integer) request.getAttribute("firstCount");
    Integer limitAttr  = (Integer) request.getAttribute("limit");

    if (firstText == null)   firstText = "(현재 등록된 문제가 없습니다)";
    if (firstQid == null)    firstQid = 0;
    if (firstCount == null)  firstCount = 0;
    if (limitAttr == null)   limitAttr = 5;  // 컨트롤러에서 기본 5
%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>말하기 퀴즈</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <style>
    body {
      font-family: system-ui, -apple-system, "Noto Sans KR", Roboto, sans-serif;
      background:#f7f8fa; margin:0; padding:20px; color:#222;
    }
    .page-wrap {
      max-width: 600px; margin: 0 auto; background:#fff; border-radius:16px;
      box-shadow:0 20px 40px rgba(0,0,0,0.08); padding:24px 24px 80px; position:relative;
    }
    .page-header { font-size:18px; font-weight:600; color:#111; margin-bottom:8px; }
    .page-desc { font-size:14px; color:#555; margin-bottom:24px; }

    .question-box {
      border:2px solid #4f46e5; border-radius:12px; padding:16px;
      background:#eef2ff; margin-bottom:16px;
    }
    .question-label { font-size:14px; font-weight:600; color:#4f46e5; display:flex; gap:8px; margin-bottom:8px; }
    .question-label-pill { font-size:11px; font-weight:500; color:#fff; background:#4f46e5; padding:2px 8px; border-radius:999px; }
    .question-text { font-size:20px; font-weight:600; color:#111; line-height:1.4; word-break:keep-all; min-height:48px; }

    .meta-row { display:flex; flex-wrap:wrap; gap:12px; font-size:13px; color:#444; margin-bottom:24px; }
    .meta-item b { color:#000; font-weight:600; }

    .controls-row { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:24px; }
    button.btn {
      appearance:none; border:0; border-radius:10px; padding:10px 14px;
      font-size:14px; font-weight:600; line-height:1.2; cursor:pointer;
      background:#e5e7eb; color:#111;
    }
    button.btn.primary { background:#4f46e5; color:#fff; }
    button.btn:disabled { background:#d1d5db; color:#777; cursor:not-allowed; }

    .result-box { border-top:1px solid #ddd; padding-top:16px; }
    .result-title { font-size:15px; font-weight:600; margin-bottom:8px; }
    .result-line { font-size:14px; margin-bottom:6px; }
    .result-line .label { display:inline-block; min-width:70px; font-weight:600; color:#555; }

    .footer-hint { font-size:12px; color:#888; text-align:center; margin-top:32px; }

    /* ===== 완료 모달 ===== */
    .modal-backdrop {
      position: fixed; inset: 0; background: rgba(15,23,42,.5);
      display: none; align-items: center; justify-content: center; z-index: 9999;
    }
    .modal {
      width: min(92vw, 520px); background: #fff; border-radius: 14px;
      box-shadow: 0 30px 60px rgba(0,0,0,.25); overflow: hidden;
      transform: translateY(10px); opacity: 0; transition: .18s ease;
    }
    .modal.show { transform: translateY(0); opacity: 1; }
    .modal-header {
      background: #eef2ff; border-bottom: 1px solid #dbeafe; padding: 16px 20px;
      display: flex; align-items: center; gap: 8px; color: #1f2937; font-weight: 800;
    }
    .modal-body { padding: 18px 20px 8px; color:#374151; }
    .modal-body p { margin: 0 0 10px 0; line-height: 1.5; }
    .modal-footer {
      padding: 14px 20px 20px; display: flex; gap: 10px; flex-wrap: wrap; justify-content: flex-end;
    }
    .m-btn {
      appearance:none; border: 1px solid #e5e7eb; background: #fff; color: #111827;
      padding: 10px 14px; border-radius: 10px; font-weight: 700; cursor: pointer;
    }
    .m-btn.primary { background: #4f46e5; color:#fff; border-color:#4f46e5; }
    .m-btn:hover { filter: brightness(1.03); }
  </style>
</head>
<body>

<div class="page-wrap">
  <div class="page-header">말하기 연습 퀴즈</div>
  <div class="page-desc">문장을 듣고, 그대로 말해 보세요. 정확도에 따라 점수가 나옵니다.</div>

  <!-- 문제 영역 -->
  <div class="question-box">
    <div class="question-label">
      <span>문제</span>
      <span class="question-label-pill">영어 문장을 따라 말해보세요</span>
    </div>
    <div id="question" class="question-text"><%= firstText %></div>
  </div>

  <!-- 메타 -->
  <div class="meta-row">
    <div class="meta-item"><b>문제 ID:</b> <span id="qid"><%= firstQid %></span></div>
    <div class="meta-item"><b>진행 수:</b> <span id="count"><%= firstCount %></span> / <span id="limit"><%= limitAttr %></span></div>
  </div>

  <!-- 버튼들 -->
  <div class="controls-row">
    <button id="btnNext" class="btn">다음 문제 ⏭</button>
    <button id="btnListen" class="btn primary">듣기 🔊</button>
    <button id="btnRecStart" class="btn">말하기 시작 🎙</button>
    <button id="btnRecStop" class="btn" disabled>말하기 끝 ⏹</button>
  </div>

  <!-- 결과 -->
  <div class="result-box">
    <div class="result-title">내 결과</div>
    <div class="result-line"><span class="label">내 발화:</span> <span id="said"></span></div>
    <div class="result-line"><span class="label">점수:</span> <span id="score"></span></div>
    <div class="result-line"><span class="label">판정:</span> <span id="correct"></span></div>
  </div>

  <div class="footer-hint">
    "다음 문제"를 누르면 새로운 문장이 나와요. <br/>
    "말하기 시작 → 말하기 끝" 후 자동 채점됩니다.
  </div>
</div>

<!-- ===== 완료 모달 ===== -->
<div id="finishBackdrop" class="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="finishTitle" aria-hidden="true">
  <div id="finishModal" class="modal" role="document">
    <div class="modal-header">
      ✅ <div id="finishTitle">퀴즈 완료</div>
    </div>
    <div class="modal-body">
      <p>수고했어요! 오늘 퀴즈를 모두 마쳤습니다.</p>
      <p>다음으로 어디로 갈까요?</p>
    </div>
    <div class="modal-footer">
      <button class="m-btn" id="goHome">메인으로</button>
      <button class="m-btn primary" id="goProgress">내 성과 보러가기</button>
    </div>
  </div>
</div>

<script>
  const BASE  = '${ctx}/quiz';
  const HOME  = '${ctx}/main';          // 메인 페이지 경로(프로젝트별로 맞춰져 있으면 OK)
  const PROG  = '${ctx}/quiz/progress'; // 성과 페이지

  const LIMIT = <%= limitAttr %>;

  const $ = (id) => document.getElementById(id);

  // ---- 모달 ----
  function showFinishModal() {
    const bd = $('finishBackdrop');
    const md = $('finishModal');
    bd.style.display = 'flex';
    // reflow 후 애니메이션
    requestAnimationFrame(() => md.classList.add('show'));
    // 포커스 편의
    setTimeout(() => $('goProgress').focus(), 50);
    // 버튼 비활성 (종료 상태)
    disableAllControls();
  }
  function hideFinishModal() {
    const bd = $('finishBackdrop');
    const md = $('finishModal');
    md.classList.remove('show');
    setTimeout(() => bd.style.display = 'none', 150);
  }
  function disableAllControls() {
    ['btnNext','btnListen','btnRecStart','btnRecStop'].forEach(id=>{
      const el = $(id);
      if (el) el.disabled = true;
    });
  }

  // ---- 전역 상태 ----
  let curQid = <%= firstQid %> || null;
  let mediaRecorder = null;
  let chunks = [];

  function getCount() {
    const n = parseInt(($('count').innerText||'0').trim(), 10);
    return isNaN(n) ? 0 : n;
  }

  // ---- 다음 문제 불러오기 ----
  async function fetchNext() {
    // 이미 제한에 도달했다면 바로 모달
    if (getCount() >= LIMIT) {
      showFinishModal();
      return;
    }

    try {
      const res  = await fetch(BASE + '/next');
      const data = await res.json();

      if (!data.ok) {
        // 서버가 finished를 알려주면 모달
        if (data.finished) showFinishModal();
        else alert('문제를 가져올 수 없습니다.');
        return;
      }

      curQid = data.qid;
      const newCount = getCount() + 1;

      $('qid').innerText   = curQid;
      $('question').innerText = data.text || '';
      $('count').innerText = newCount;

      $('btnListen').disabled = false;
      $('btnRecStart').disabled = false;
      $('btnRecStop').disabled  = true;

      // 이 문제로 5개째면, 정답 채점 뒤에 모달 띄우도록(아래 stopRecAndSend에서 처리)
      if (newCount > LIMIT) {
        // 방어 로직: 혹시 서버/클라이언트 불일치시 즉시 종료
        $('count').innerText = LIMIT;
        showFinishModal();
      }

    } catch (e) {
      console.error(e);
      alert('다음 문제가 오류가 발생했습니다.');
    }
  }

  // ---- TTS ----
  async function playTts() {
    if (!curQid) return alert('먼저 문제를 불러와 주세요.');
    const ttsRes = await fetch(BASE + '/ttsByQid?qid=' + curQid);
    if (!ttsRes.ok) return alert('TTS 생성 실패');
    const blob = await ttsRes.blob();
    const url  = URL.createObjectURL(blob);
    const audio = new Audio(url);
    audio.play();
  }

  // ---- 녹음 ----
  async function startRec() {
    if (!curQid) return alert('먼저 문제를 불러와 주세요.');
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio:true });
      mediaRecorder = new MediaRecorder(stream);
      chunks = [];
      mediaRecorder.ondataavailable = e => { if (e.data && e.data.size) chunks.push(e.data); };
      mediaRecorder.start();
      $('btnRecStart').disabled = true;
      $('btnRecStop').disabled  = false;
    } catch (err) {
      console.error(err);
      alert('마이크 권한을 허용해주세요.');
    }
  }

  async function stopRecAndSend() {
    if (!mediaRecorder) return;

    mediaRecorder.onstop = async () => {
      const blob = new Blob(chunks, { type: 'audio/webm' });
      const fd   = new FormData();
      fd.append('file', blob);
      fd.append('qid',  curQid);

      const res  = await fetch(BASE + '/stt', { method:'POST', body:fd });
      if (!res.ok) {
        alert('음성 인식 중 오류가 발생했습니다.');
        $('btnRecStart').disabled = false;
        $('btnRecStop').disabled  = true;
        return;
      }

      const data = await res.json();
      if (!data.ok) {
        alert('음성 인식에 실패했습니다. reason=' + (data.reason||'unknown'));
      } else {
        $('said').innerText    = data.said || '';
        $('score').innerText   = (data.score ?? '').toString();
        $('correct').innerText = data.correct ? '정답' : '오답';

        // ★ 이 문제가 LIMIT번째였다면, 바로 완료 모달 오픈
        const cur = getCount();
        const lim = parseInt(($('limit').innerText||'5'), 10);
        if (!isNaN(cur) && !isNaN(lim) && cur >= lim) {
          showFinishModal();
          return;
        }
      }

      $('btnRecStart').disabled = false;
      $('btnRecStop').disabled  = true;
    };

    mediaRecorder.stop();
  }

  // ---- 이벤트 바인딩 ----
  window.addEventListener('DOMContentLoaded', () => {
    $('btnNext').onclick    = fetchNext;
    $('btnListen').onclick  = playTts;
    $('btnRecStart').onclick= startRec;
    $('btnRecStop').onclick = stopRecAndSend;

    // 모달 버튼
    $('goHome').onclick     = () => location.href = HOME;
    $('goProgress').onclick = () => location.href = PROG;

    // 초기 버튼 상태
    if (curQid && curQid !== 0) {
      $('btnListen').disabled = false;
      $('btnRecStart').disabled = false;
      $('btnRecStop').disabled  = true;
    } else {
      disableAllControls();
    }
  });
</script>

</body>
</html>
