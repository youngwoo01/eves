<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
  <meta charset="UTF-8">
  <title>동영상 업로드</title>
  <style>
    body{font-family:system-ui, sans-serif; margin:24px;}
    .wrap{max-width:820px; margin:0 auto;}
    .row{margin-bottom:16px;}
    label{display:block; margin-bottom:6px; font-weight:600;}
    input[type="number"],input[type="text"]{width:100%; padding:10px; box-sizing:border-box;}
    .drop{border:2px dashed #bbb; border-radius:12px; padding:24px; text-align:center;}
    .drop.drag{border-color:#888; background:#fafafa;}
    .actions{display:flex; gap:8px; align-items:center;}
    progress{width:100%; height:16px;}
    .thumb{margin-top:10px; max-width:100%; display:none;}
    .msg{margin-top:10px; font-weight:600;}
    .card{border:1px solid #e5e7eb; border-radius:12px; padding:16px; margin-bottom:24px;}
    .title{font-size:18px; font-weight:700; margin-bottom:8px;}
  </style>
</head>
<body>
<div class="wrap">
  <h2>동영상 업로드</h2>

  <!-- [A] 기존 주차에 영상 교체(UPDATE) -->
  <div class="card">
    <div class="title">A) 기존 주차에 업로드(교체)</div>
    <form id="formUpdate" method="post" action="<c:url value='/video/uploadToWeek'/>" enctype="multipart/form-data">
      <div class="row">
        <label for="wno">주차 번호(wno)</label>
        <input type="number" id="wno" name="wno" placeholder="예: 1" required />
      </div>

      <div class="row">
        <label>동영상 파일</label>
        <div id="dropA" class="drop">
          이 영역에 파일을 끌어다 놓거나 아래 버튼으로 선택하세요.
          <br/><br/>
          <input type="file" id="fileA" name="file" accept="video/*" required />
        </div>
        <video id="previewA" class="thumb" controls muted></video>
      </div>

      <!-- Spring Security CSRF 사용 시 주석 해제 -->
      <!-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> -->

      <div class="row actions">
        <button type="submit">업로드 시작</button>
        <progress id="barA" value="0" max="100"></progress>
        <span id="percentA">0%</span>
      </div>
      <div id="msgA" class="msg"></div>
    </form>
  </div>

  <!-- [B] 새 주차 만들며 업로드(INSERT) -->
  <div class="card">
    <div class="title">B) 새 주차 만들며 업로드</div>
    <form id="formInsert" method="post" action="<c:url value='/video/uploadAndCreateWeek'/>" enctype="multipart/form-data">
      <div class="row">
        <label for="lno">레슨 번호(lno)</label>
        <input type="number" id="lno" name="lno" placeholder="예: 101" required />
      </div>
      <div class="row">
        <label for="wname">주차명(wname)</label>
        <input type="text" id="wname" name="wname" placeholder="예: 1주차 - 도입" required />
      </div>
      <div class="row">
        <label>동영상 파일</label>
        <div id="dropB" class="drop">
          이 영역에 파일을 끌어다 놓거나 아래 버튼으로 선택하세요.
          <br/><br/>
          <input type="file" id="fileB" name="file" accept="video/*" required />
        </div>
        <video id="previewB" class="thumb" controls muted></video>
      </div>

      <!-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> -->

      <div class="row actions">
        <button type="submit">업로드 시작</button>
        <progress id="barB" value="0" max="100"></progress>
        <span id="percentB">0%</span>
      </div>
      <div id="msgB" class="msg"></div>
    </form>
  </div>
</div>

<script>
  // 공용 유틸: 미리보기 + 드래그앤드롭 + 업로드 진행바
  function bindUploadForm(formId, fileInputId, dropId, previewId, barId, percentId, msgId, onSuccessRedirect) {
    const form = document.getElementById(formId);
    const fileInput = document.getElementById(fileInputId);
    const drop = document.getElementById(dropId);
    const preview = document.getElementById(previewId);
    const bar = document.getElementById(barId);
    const percent = document.getElementById(percentId);
    const msg = document.getElementById(msgId);

    // 미리보기
    fileInput.addEventListener('change', () => {
      const f = fileInput.files[0];
      if (!f) return;
      const url = URL.createObjectURL(f);
      preview.src = url;
      preview.style.display = 'block';
    });

    // 드래그앤드롭
    drop.addEventListener('dragover', e => { e.preventDefault(); drop.classList.add('drag'); });
    drop.addEventListener('dragleave', e => drop.classList.remove('drag'));
    drop.addEventListener('drop', e => {
      e.preventDefault(); drop.classList.remove('drag');
      if (e.dataTransfer.files.length) {
        fileInput.files = e.dataTransfer.files;
        fileInput.dispatchEvent(new Event('change'));
      }
    });

    // 제출 (XHR로 진행률)
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const fd = new FormData(form);
      const xhr = new XMLHttpRequest();
      xhr.open('POST', form.action, true);

      xhr.upload.onprogress = (ev) => {
        if (ev.lengthComputable) {
          const p = Math.round((ev.loaded / ev.total) * 100);
          bar.value = p; percent.textContent = p + '%';
        }
      };
      xhr.onload = () => {
        if (xhr.status === 200 && xhr.responseText.startsWith('OK:')) {
          const id = xhr.responseText.split(':')[1];
          msg.textContent = '업로드 및 변환 성공! ID: ' + id;
          if (onSuccessRedirect) onSuccessRedirect(id);
        } else {
          msg.textContent = '실패: ' + xhr.responseText;
        }
      };
      xhr.onerror = () => { msg.textContent = '업로드 중 오류가 발생했습니다.'; };
      xhr.send(fd);
    });
  }

  // A) 기존 주차 업로드: 성공 후 재생 페이지로 이동하고 싶으면 아래 주석 해제
  bindUploadForm(
    'formUpdate','fileA','dropA','previewA','barA','percentA','msgA',
    function(/*videoId*/) {
      const wno = document.getElementById('wno').value;
      // window.location.href = '<c:url value="/weeks/play"/>' + '/' + wno;
    }
  );

  // B) 새 주차 업로드: 성공 후 새로 발급된 wno(videoId)로 재생 페이지 이동
  bindUploadForm(
    'formInsert','fileB','dropB','previewB','barB','percentB','msgB',
    function(videoId) {
      // window.location.href = '<c:url value="/weeks/play"/>' + '/' + videoId;
    }
  );
</script>
</body>
</html>
