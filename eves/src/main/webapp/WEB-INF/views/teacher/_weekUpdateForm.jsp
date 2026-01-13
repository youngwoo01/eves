<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="card update-form-card">
  <div class="title">${param.wname} (영상 교체)</div>
  
  <form id="formUpdate_${param.wno}" method="post" action="${pageContext.request.contextPath}/video/uploadToWeek" enctype="multipart/form-data">
    
    <input type="hidden" name="wno" value="${param.wno}" />
    <input type="hidden" name="wname" value="${param.wname}" />
    <input type="hidden" name="lno" value="${param.lno}" />
    
    <div class="row">
      <label>새 동영상 파일</label>
      <div id="drop_${param.wno}" class="drop">
        이 영역에 파일을 끌어다 놓거나 아래 버튼으로 선택하세요.
        <br/><br/>
        <input type="file" id="file_${param.wno}" name="file" accept="video/*" required />
      </div>
      <video id="preview_${param.wno}" class="thumb" controls muted></video>
    </div>

    <div class="row actions">
      <button type="submit">업로드 시작</button>
      <progress id="bar_${param.wno}" value="0" max="100"></progress>
      <span id="percent_${param.wno}">0%</span>
    </div>
    <div id="msg_${param.wno}" class="msg"></div>
  </form>
</div>
