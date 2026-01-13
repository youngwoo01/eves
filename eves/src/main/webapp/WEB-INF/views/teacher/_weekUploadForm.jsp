<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  이 파일은 week.jsp에 포함될 주차 업로드 폼입니다.
  단독으로 사용되지 않으며, week.jsp로부터 lesson.lno 값을 전달받습니다.
--%>
<div class="card">
  <div class="title">새로운 주차 추가</div>
  
  <form id="formInsert" method="post" action="${pageContext.request.contextPath}/video/uploadAndCreateWeek" enctype="multipart/form-data">
    
    <input type="hidden" id="lno" name="lno" value="${lesson.lno}" required />
    
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

    <div class="row actions">
      <button type="submit">주차 추가하기</button>
      <progress id="barB" value="0" max="100"></progress>
      <span id="percentB">0%</span>
    </div>
    <div id="msgB" class="msg"></div>
  </form>
</div>

<script>
  function bindUploadForm(formId, fileInputId, dropId, previewId, barId, percentId, msgId, onSuccessRedirect) {
    const form = document.getElementById(formId);
    const fileInput = document.getElementById(fileInputId);
    const drop = document.getElementById(dropId);
    const preview = document.getElementById(previewId);
    const bar = document.getElementById(barId);
    const percent = document.getElementById(percentId);
    const msg = document.getElementById(msgId);

    fileInput.addEventListener('change', () => {
      const f = fileInput.files[0];
      if (!f) return;
      const url = URL.createObjectURL(f);
      preview.src = url;
      preview.style.display = 'block';
    });

    drop.addEventListener('dragover', e => { e.preventDefault(); drop.classList.add('drag'); });
    drop.addEventListener('dragleave', e => drop.classList.remove('drag'));
    drop.addEventListener('drop', e => {
      e.preventDefault(); drop.classList.remove('drag');
      if (e.dataTransfer.files.length) {
        fileInput.files = e.dataTransfer.files;
        fileInput.dispatchEvent(new Event('change'));
      }
    });

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
        if (xhr.status === 200) {
            msg.textContent = '업로드 성공!';
            window.location.reload(); 
        } else {
            msg.textContent = '실패: ' + xhr.responseText;
        }
      };
      xhr.onerror = () => { msg.textContent = '업로드 중 오류가 발생했습니다.'; };
      xhr.send(fd);
    });
  }

  bindUploadForm(
    'formInsert','fileB','dropB','previewB','barB','percentB','msgB'
  );
</script>
