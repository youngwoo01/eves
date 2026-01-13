<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>영상 재생</title>
  <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
  <style>
    :root{
      --bg:#0f0f0f; --panel:#181818; --muted:#aaa; --solid:#fff; --brand:#2b6ded;
    }
    body{margin:0;padding:24px;font-family:system-ui,sans-serif;background:#fff;}
    .wrap{max-width:960px;margin:0 auto;}
    .player-shell{position:relative;background:#000;border-radius:12px;overflow:hidden;}
    video{width:100%;max-height:70vh;display:block;background:#000;}
    /* 컨트롤 바 */
    .controls{position:absolute;left:0;right:0;bottom:0;display:flex;flex-direction:column;
      gap:8px;padding:10px;background:linear-gradient(to top, rgba(0,0,0,.55), rgba(0,0,0,0));}
    .progress{height:6px; background:rgba(255,255,255,.25); cursor:pointer; border-radius:99px; position:relative;}
    .progress__filled{height:100%; width:0%; background:var(--brand); border-radius:99px;}
    .row{display:flex;align-items:center;gap:10px;justify-content:space-between;}
    .left,.right{display:flex;align-items:center;gap:10px;}
    .btn{appearance:none;border:0;background:transparent;color:#fff;cursor:pointer;font-size:14px;padding:6px 8px;border-radius:8px}
    .btn:hover{background:rgba(255,255,255,.1)}
    .time{color:#fff;font-variant-numeric:tabular-nums;font-size:13px}
    .vol{width:100px}
    .pill{color:#fff;background:rgba(255,255,255,.1);padding:4px 8px;border-radius:999px;font-size:12px}
    .topbar{position:absolute;left:0;right:0;top:0;display:flex;justify-content:space-between;align-items:center;
      padding:8px 10px;color:#fff;background:linear-gradient(to bottom, rgba(0,0,0,.45), rgba(0,0,0,0));}
    .title{font-weight:700}
    .done-bar{display:none;gap:12px;align-items:center;justify-content:space-between;margin-top:14px;
      padding:12px 14px;border:1px solid #ddd;border-radius:10px;background:#fafafa;}
    .btn-primary{padding:10px 14px;border:0;border-radius:10px;cursor:pointer;font-weight:600;background:#2b6ded;color:#fff}
    .hint{color:#666;font-size:12px;margin-top:6px}
  </style>
</head>
<body>
<div class="wrap">

  <!-- 상단 제목/뱃지 -->
  <div style="display:flex;align-items:center;gap:8px;margin:0 0 10px 2px">
    <div class="pill">HLS</div>
    <div class="title">학습 영상</div>
  </div>

  <div class="player-shell" id="playerShell">
    <div class="topbar">
      <div class="title"><c:out value="${videoTitle != null ? videoTitle : '레슨 영상'}"/></div>
      <div class="pill">wno: <c:out value="${wno}"/></div>
    </div>

    <!-- 비디오 -->
    <video id="player"
           playsinline
           poster="<c:out value='${thumbUrl}'/>"
           data-src="<c:out value='${playUrl}'/>"></video>

    <!-- 커스텀 컨트롤 -->
    <div class="controls" id="controls">
      <div class="progress" id="progress">
        <div class="progress__filled" id="progressFilled"></div>
      </div>
      <div class="row">
        <div class="left">
          <button class="btn" id="playPause">▶︎/Ⅱ</button>
          <button class="btn" id="back10">⏪ 10s</button>
          <button class="btn" id="fwd10">⏩ 10s</button>
          <div class="time"><span id="cur">0:00</span> / <span id="dur">0:00</span></div>
          <input class="vol" id="volume" type="range" min="0" max="1" step="0.01" value="1">
        </div>
        <div class="right">
          <select class="btn" id="speed">
            <option value="0.75">0.75x</option>
            <option value="1" selected>1x</option>
            <option value="1.25">1.25x</option>
            <option value="1.5">1.5x</option>
            <option value="2">2x</option>
          </select>
          <button class="btn" id="pipBtn">PiP</button>
          <button class="btn" id="fsBtn">⤢</button>
        </div>
      </div>
    </div>
  </div>

  <!-- ===== PRG용 히든필드 구성 ===== -->
  <c:set var="wnoVal" value="${empty wno ? param.wno : wno}"/>
  <c:set var="lnoVal" value="${empty lno ? param.lno : lno}"/>

  <!-- 완료 폼 (서블릿으로 submit) -->
  <!-- action: /week/complete (JindoController에서 처리) -->
  <form id="completeForm" action="<c:out value='${pageContext.request.contextPath}'/>/week/complete" method="post">
    <input type="hidden" name="wno" value="<c:out value='${wnoVal}'/>">
    <c:if test="${not empty lnoVal}">
      <input type="hidden" name="lno" value="<c:out value='${lnoVal}'/>">
    </c:if>

    <!-- ✅ 컨텍스트 없는 경로로 returnUrl 전달(중복 /eves 방지) -->
    <input type="hidden" name="returnUrl"
           value="/user/myWeek<c:if test='${not empty lnoVal}'>?lno=${lnoVal}</c:if>" />

    <!-- CSRF -->
    <c:if test="${not empty _csrf}">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    </c:if>
  </form>

  <!-- 끝나면 나타나는 바 + 버튼 -->
  <div id="doneBar" class="done-bar">
    <div>영상 시청이 완료되었습니다. 버튼을 눌러 진도를 저장합니다.</div>
    <button id="completeBtn" type="button" class="btn-primary">진도 완료 저장</button>
  </div>

  <div class="hint">단축키: <b>Space</b> 재생/일시정지, <b>J</b> 10초 뒤로, <b>L</b> 10초 앞으로, <b>↑/↓</b> 볼륨</div>
</div>

<script>
(function () {
  const ctx = '<c:out value="${pageContext.request.contextPath}"/>' || '';
  const video = document.getElementById('player');
  const progress = document.getElementById('progress');
  const progressFilled = document.getElementById('progressFilled');
  const playPause = document.getElementById('playPause');
  const back10 = document.getElementById('back10');
  const fwd10 = document.getElementById('fwd10');
  const volume = document.getElementById('volume');
  const speed = document.getElementById('speed');
  const pipBtn = document.getElementById('pipBtn');
  const fsBtn = document.getElementById('fsBtn');
  const doneBar = document.getElementById('doneBar');
  const completeBtn = document.getElementById('completeBtn');
  const form = document.getElementById('completeForm');

  const curEl = document.getElementById('cur');
  const durEl = document.getElementById('dur');

  // wno
  const wno = form.querySelector('input[name="wno"]')?.value;
  if (!wno) console.warn('wno가 없습니다. /week/play?wno=... 로 호출하거나 모델에 넣어주세요.');

  // 소스 결정: 서버에서 내려준 data-src 우선, 없으면 wno로 구성
  let src = video.getAttribute('data-src');
  if (!src || src.trim()==='') {
    if (wno) src = `${ctx}/play/${wno}/master.m3u8`;
  }

  // HLS 초기화
  if (src) {
    if (window.Hls && Hls.isSupported() && src.endsWith('.m3u8')) {
      const hls = new Hls();
      hls.loadSource(src);
      hls.attachMedia(video);
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      video.src = src;
    } else {
      video.src = src;
    }
  }

  function fmt(t){
    if (!isFinite(t)) return '0:00';
    const s = Math.floor(t%60).toString().padStart(2,'0');
    const m = Math.floor(t/60)%60;
    const h = Math.floor(t/3600);
    return h>0 ? `${h}:${m.toString().padStart(2,'0')}:${s}` : `${m}:${s}`;
  }

  video.addEventListener('loadedmetadata', () => {
    durEl.textContent = fmt(video.duration || 0);
  });

  video.addEventListener('timeupdate', () => {
    curEl.textContent = fmt(video.currentTime || 0);
    const ratio = (video.currentTime || 0) / (video.duration || 1);
    progressFilled.style.width = `${ratio*100}%`;
  });

  // 진행바 탐색
  let seeking = false;
  function seek(e){
    const rect = progress.getBoundingClientClientRect ? progress.getBoundingClientRect() : progress.getClientRects()[0];
    const pct = Math.min(1, Math.max(0, (e.clientX - rect.left)/rect.width));
    video.currentTime = pct * (video.duration || 0);
  }
  progress.addEventListener('mousedown', (e)=>{ seeking=true; seek(e); });
  window.addEventListener('mousemove', (e)=>{ if(seeking) seek(e); });
  window.addEventListener('mouseup', ()=> seeking=false);

  // 컨트롤
  const toggle = ()=> video.paused ? video.play() : video.pause();
  playPause.addEventListener('click', toggle);
  back10.addEventListener('click', ()=> video.currentTime = Math.max(0, video.currentTime - 10));
  fwd10.addEventListener('click', ()=> video.currentTime = Math.min(video.duration||0, video.currentTime + 10));
  volume.addEventListener('input', ()=> video.volume = Number(volume.value));
  speed.addEventListener('change', ()=> video.playbackRate = Number(speed.value));
  fsBtn.addEventListener('click', ()=>{
    const shell = document.getElementById('playerShell');
    if (!document.fullscreenElement) shell.requestFullscreen?.();
    else document.exitFullscreen?.();
  });
  pipBtn.addEventListener('click', async ()=>{
    if (document.pictureInPictureEnabled && !video.disablePictureInPicture) {
      if (document.pictureInPictureElement) await document.exitPictureInPicture();
      else await video.requestPictureInPicture();
    }
  });

  // 단축키
  window.addEventListener('keydown', (e)=>{
    if (['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) return;
    if (e.code === 'Space') { e.preventDefault(); toggle(); }
    if (e.key.toLowerCase() === 'j') video.currentTime = Math.max(0, video.currentTime - 10);
    if (e.key.toLowerCase() === 'l') video.currentTime = Math.min(video.duration||0, video.currentTime + 10);
    if (e.key === 'ArrowUp')   { e.preventDefault(); video.volume = Math.min(1, video.volume + 0.05); volume.value = video.volume; }
    if (e.key === 'ArrowDown') { e.preventDefault(); video.volume = Math.max(0, video.volume - 0.05); volume.value = video.volume; }
  });

  // 영상 끝 → 완료바
  video.addEventListener('ended', () => {
    doneBar.style.display = 'flex';
    completeBtn?.focus();
  });

  // 완료 저장 → 서버 PRG 리다이렉트
  completeBtn?.addEventListener('click', () => {
    if (completeBtn.disabled) return;
    completeBtn.disabled = true;
    completeBtn.textContent = '저장 중...';
    document.getElementById('completeForm').submit();
  });
})();
</script>
</body>
</html>
