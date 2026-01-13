<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>음성 퀴즈</title>

  <style>
    :root {
      --bg-main: #f7faff;
      --card-bg: #ffffff;
      --accent: #4f46e5;
      --accent-light: #eef2ff;
      --text-main: #1e293b;
      --text-dim: #64748b;
      --border-soft: #e2e8f0;
      --radius-lg: 20px;
      --radius-sm: 10px;
    }

    * {
      box-sizing: border-box;
      -webkit-font-smoothing: antialiased;
    }

    body {
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Pretendard", "Noto Sans KR", sans-serif;
      margin: 0;
      background: radial-gradient(circle at 20% 20%, #eef2ff 0%, #f7faff 60%);
      color: var(--text-main);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }

    .quiz-wrapper {
      width: 100%;
      max-width: 480px;
    }

    .quiz-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      box-shadow:
        0 24px 40px rgba(15, 23, 42, 0.08),
        0 4px 8px rgba(15, 23, 42, 0.04);
      border: 1px solid var(--border-soft);
      padding: 24px 24px 20px;
    }

    .quiz-header {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin-bottom: 20px;
    }

    .title-row {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
    }

    .title-wrap {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .page-title {
      font-size: 1rem;
      font-weight: 600;
      color: var(--text-main);
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .page-title-badge {
      font-size: .7rem;
      font-weight: 600;
      background: var(--accent);
      color: #fff;
      padding: 2px 8px;
      border-radius: var(--radius-sm);
      line-height: 1.4;
    }

    .sub-info {
      font-size: .75rem;
      font-weight: 500;
      color: var(--text-dim);
    }

    /* 진행상태 표시 박스 */
    .progress-box {
      font-size: .8rem;
      font-weight: 500;
      color: var(--text-dim);
      background: #fff;
      border: 1px solid var(--border-soft);
      border-radius: var(--radius-sm);
      padding: 8px 12px;
      line-height: 1.4;
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .progress-box b {
      color: var(--text-main);
    }

    .question-box {
      background: var(--accent-light);
      border: 1px solid #c7d2fe;
      border-radius: 14px;
      padding: 16px 16px 14px;
      margin-bottom: 20px;
    }

    .question-label {
      font-size: .75rem;
      font-weight: 600;
      color: var(--accent);
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .question-label-pill {
      background: #fff;
      color: var(--accent);
      border-radius: 999px;
      padding: 2px 8px;
      font-size: .7rem;
      border: 1px solid #c7d2fe;
      line-height: 1.2;
      font-weight: 600;
    }

    .question-text {
      font-size: 1rem;
      font-weight: 600;
      color: var(--text-main);
      line-height: 1.5;
      word-break: keep-all;
    }

    /* 버튼 영역 */
    .controls {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 10px;
      margin-bottom: 20px;
    }

    .action-btn {
      appearance: none;
      border: 0;
      border-radius: var(--radius-sm);
      font-size: .9rem;
      font-weight: 600;
      padding: 12px 10px;
      line-height: 1.3;
      cursor: pointer;
      transition: all .15s ease;
      box-shadow:
        0 10px 20px rgba(15, 23, 42, 0.08),
        0 2px 4px rgba(15, 23, 42, 0.04);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      text-align: center;
    }

    .action-btn:disabled {
      opacity: .4;
      cursor: not-allowed;
      box-shadow: none;
    }

    .btn-primary {
      background: var(--accent);
      color: #fff;
    }
    .btn-primary:not(:disabled):hover {
      filter: brightness(1.05);
      box-shadow:
        0 16px 24px rgba(79,70,229,.22),
        0 4px 8px rgba(0,0,0,.06);
    }

    .btn-ghost {
      background: #fff;
      color: var(--text-main);
      border: 2px solid var(--border-soft);
    }
    .btn-ghost:not(:disabled):hover {
      background: #f8fafc;
    }

    /* 결과 영역 */
    .result-card {
      border: 1px solid var(--border-soft);
      background: #fff;
      border-radius: var(--radius-lg);
      padding: 16px 16px 12px;
      box-shadow: 0 12px 20px rgba(15,23,42,.05);
    }

    .result-row {
      font-size: .9rem;
      margin-bottom: 10px;
      line-height: 1.4;
    }

    .result-label {
      font-size: .75rem;
      font-weight: 600;
      color: var(--text-dim);
      margin-bottom: 4px;
      display: block;
    }

    .result-value {
      font-size: .95rem;
      font-weight: 600;
      color: var(--text-main);
      word-break: break-word;
      min-height: 1.4em;
    }

    .score-value {
      font-weight: 700;
      font-size: 1rem;
    }

    .tag-correct {
      display: inline-block;
      background: #10b98120;
      color: #059669;
      border: 1px solid #6ee7b7;
      border-radius: 999px;
      padding: 2px 8px;
      font-size: .7rem;
      font-weight: 600;
      line-height: 1.2;
      margin-left: 8px;
    }

    .tag-wrong {
      display: inline-block;
      background: #fee2e2;
      color: #dc2626;
      border: 1px solid #fecaca;
      border-radius: 999px;
      padding: 2px 8px;
      font-size: .7rem;
      font-weight: 600;
      line-height: 1.2;
      margin-left: 8px;
    }

    .hint {
      font-size: .7rem;
      color: var(--text-dim);
      text-align: center;
      margin-top: 14px;
      line-height: 1.4;
    }

    .session-stats {
      margin-top: 16px;
      font-size: .8rem;
      color: var(--text-dim);
      line-height: 1.4;
      text-align: center;
    }
    .session-stats b {
      color: var(--text-main);
    }
  </style>
</head>
<body>
<div class="quiz-wrapper">
  <div class="quiz-card">

    <!-- 헤더 + 진행상태 -->
    <div class="quiz-header">
      <div class="title-row">
        <div class="title-wrap">
          <div class="page-title">
            <span>음성 퀴즈</span>
            <span class="page-title-badge">연습 모드</span>
          </div>
          <div class="sub-info">
            사용자 번호 <b>${uno}</b>
          </div>
        </div>

        <div class="progress-box">
          <div>전체 <b><span id="limit">${limit}</span></b>문제</div>
          <div>현재 <b><span id="count">0</span></b> / <span id="limit2">${limit}</span></div>
          <div>QID <b><span id="qid">-</span></b></div>
        </div>
      </div>
    </div>

    <!-- 문제 (서버에서 첫 문제 텍스트는 안 줘. 듣기 버튼으로 TTS만 들려줄 수도 있음)
         여기 question-text는 지금은 placeholder처럼 둘게.
         만약 문제 텍스트를 그대로 화면에 안 보여주고 귀로만 듣게 하고 싶으면 이 블럭 자체를 숨겨도 돼. -->
    <div class="question-box">
      <div class="question-label">
        <span>문제</span>
        <span class="question-label-pill">듣고 따라 말해보세요</span>
      </div>
      <div id="question" class="question-text">
        (문제를 들으려면 🔊 듣기 버튼을 누르세요)
      </div>
    </div>

    <!-- 버튼 그룹 -->
    <div class="controls">
      <button id="btnNext" class="action-btn btn-primary">
        ⏭ 다음 문제
      </button>

      <button id="btnListen" class="action-btn btn-ghost" disabled>
        🔊 듣기
      </button>

      <button id="btnRec" class="action-btn btn-ghost" disabled>
        🎙 말하기 시작
      </button>

      <button id="btnStop" class="action-btn btn-ghost" disabled>
        ⏹ 정지 & 채점
      </button>
    </div>

    <!-- 결과 영역 -->
    <div class="result-card">
      <div class="result-row">
        <span class="result-label">내가 말한 내용</span>
        <span id="said" class="result-value">(아직 없음)</span>
      </div>

      <div class="result-row">
        <span class="result-label">판정 / 점수</span>
        <span class="result-value">
          <span id="result" class="score-value"></span>
        </span>
      </div>
    </div>

    <div class="session-stats">
      <div>정답 수: <b><span id="correctCnt">0</span></b> / <span id="limit3">${limit}</span></div>
      <div>평균 점수: <b><span id="avg">0</span></b> 점</div>
    </div>

    <div class="hint">
      ⏭ 다음 문제 → 🔊 듣기 → 🎙 말하기 시작 → ⏹ 정지 & 채점
    </div>

  </div>
</div>

<script>
  const uno = ${uno}; // 서버에서 전달됨

  let curQid = null;
  let count = 0;
  let correctCnt = 0;
  let scoreSum = 0;

  let mediaRecorder;
  let audioChunks = [];

  const $ = (id) => document.getElementById(id);

  async function fetchNext() {
    const res = await fetch('/quiz/next');
    const data = await res.json();

    if (!data.ok && data.finished) {
        $('result').innerText =
          '세션 종료! 정답 ' + correctCnt + '/' + $('limit').innerText +
          ', 평균 ' + Math.round(scoreSum / Math.max(count,1)) + '점';

        $('btnNext').disabled = true;
        $('btnListen').disabled = true;
        $('btnRec').disabled = true;
        $('btnStop').disabled = true;
        return;
    }

    if (!data.ok) {
        $('result').innerText = '문제를 가져올 수 없습니다.';
        return;
    }

    // 정상적으로 문제 하나 받았을 때
    curQid = data.qid;
    count++;

    $('qid').innerText = curQid;
    $('count').innerText = count;

    $('said').innerText = '(아직 없음)';
    $('result').innerText = '';

    // 버튼 상태 업데이트
    $('btnListen').disabled = false;
    $('btnRec').disabled = false;
    $('btnStop').disabled = true;
  }

  // 다음 문제 버튼
  $('btnNext').onclick = async () => {
    await fetchNext();
  };

  // 듣기 버튼 (TTS)
  $('btnListen').onclick = async () => {
    if (!curQid) {
      alert('먼저 문제를 불러와 주세요.');
      return;
    }

    const url = '/quiz/ttsByQid?qid=' + curQid;

    // 네트워크 상태 살짝 체크해도 됨 (원하면 주석 가능)
    try {
      const checkRes = await fetch(url, { method: 'GET' });
      if (!checkRes.ok) {
        alert('음성을 가져올 수 없습니다. (' + checkRes.status + ')');
        return;
      }
    } catch (err) {
      alert('서버에 연결할 수 없어요.');
      return;
    }

    const audio = new Audio(url);
    audio.play().catch(err => {
      console.error('재생 실패:', err);
      alert('브라우저에서 재생이 차단되었거나 오디오 형식이 이상해요.');
    });
  };

  // 말하기 시작
  $('btnRec').onclick = async () => {
    if (!curQid) {
      alert('먼저 문제를 불러와 주세요.');
      return;
    }

    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    mediaRecorder = new MediaRecorder(stream);
    audioChunks = [];

    mediaRecorder.ondataavailable = e => audioChunks.push(e.data);

    mediaRecorder.start();

    $('btnRec').disabled = true;
    $('btnStop').disabled = false;
    $('result').innerText = '녹음 중...';
  };

  // 정지 & 채점
  $('btnStop').onclick = async () => {
    if (!mediaRecorder) return;

    mediaRecorder.stop();

    $('btnStop').disabled = true;
    $('btnRec').disabled = false;

    mediaRecorder.onstop = async () => {
      const blob = new Blob(audioChunks, { type: 'audio/webm' });

      const formData = new FormData();
      formData.append('file', blob, 'answer.webm');
      formData.append('qid', curQid);

      const res = await fetch('/quiz/stt', { method: 'POST', body: formData });
      const data = await res.json();

      $('said').innerText = data.said;

      const msg = data.correct
        ? ('정답! (' + data.score + '점)')
        : ('오답 (' + data.score + '점)');

      $('result').innerText = msg;

      // 누적 결과
      if (data.correct) correctCnt++;
      scoreSum += (data.score || 0);
      $('correctCnt').innerText = correctCnt;
      $('avg').innerText = Math.round(scoreSum / count);

      // 다음 문제를 풀도록 듣기는 잠깐 막음
      $('btnListen').disabled = true;
    };
  };

  // 첫 문제 자동 로드
  fetchNext();
</script>
</body>
</html>
