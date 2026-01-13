<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>${lesson.lname} - 강의 수정</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/one.css" />
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333; }
    .container { width: 80%; margin: 50px auto; }
    .section { background-color: #fff; border: 1px solid #ddd; border-radius: 8px; padding: 30px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    h2 { border-bottom: 2px solid #007bff; padding-bottom: 10px; margin-top: 0; }
    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: bold; }
    .form-group input, .form-group select { width: 100%; padding: 10px; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; }
    .current-file { margin-top: 10px; color: #555; font-size: 14px; }
    .current-file img { max-width: 200px; border-radius: 5px; }
    .pdf-item {
        display: flex; justify-content: space-between; align-items: center;
        background-color: #f8f9fa; padding: 8px 12px; border-radius: 4px; margin-bottom: 5px;
    }
    .pdf-delete-btn {
        background-color: #dc3545; color: white; border: none; padding: 5px 8px;
        font-size: 12px; border-radius: 4px; cursor: pointer;
    }
    .btn { padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; display: inline-block; text-align: center; }
    .btn-primary { background-color: #007bff; color: white; }
    .btn-danger { background-color: #dc3545; color: white; }
    .btn-warning { background-color: #ffc107; color: #333; }
    .btn-delete {background-color: #ff0000; color: white;}
    .week-item { display: flex; justify-content: space-between; align-items: center; background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin-bottom: 10px; }
    .week-item-actions { display: flex; gap: 10px; }
    .week-edit-form { display: none; margin-top: 10px; padding: 20px; border: 1px dashed #ccc; border-radius: 8px; }

    /* ========== Upload.jsp의 스타일 추가 ========== */
    .card { border:1px solid #e5e7eb; border-radius:12px; padding:16px; margin-top: 15px; }
    .title { font-size:16px; font-weight:700; margin-bottom:12px; }
    .row { margin-bottom:16px; }
    .drop { border:2px dashed #bbb; border-radius:12px; padding:24px; text-align:center; cursor: pointer; }
    .drop.drag { border-color:#888; background:#fafafa; }
    .actions { display:flex; gap:8px; align-items:center; }
    progress { width:100%; height:16px; }
    .thumb { margin-top:10px; max-width:100%; display:none; }
    .msg { margin-top:10px; font-weight:600; }
</style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/include/header.jsp" />
    <div class="container">
        <div class="section">
            <h2>강의 정보 수정</h2>
            <form action="${pageContext.request.contextPath}/teacher/lessonEditOk" method="post" enctype="multipart/form-data">
                <input type="hidden" name="lno" value="${lesson.lno}">
                <div class="form-group">
                    <label>강의명</label>
                    <input type="text" name="lname" value="${lesson.lname}" required>
                </div>
                <div class="form-group">
                    <label>썸네일 (변경할 경우에만 선택)</label>
                    <input type="file" name="thumbnailFile">
                    <div class="current-file">
                        <p>현재 썸네일:</p>
                        <img src="${pageContext.request.contextPath}/image/${lesson.lsum}" alt="현재 썸네일">
                    </div>
                </div>
                
                <div class="form-group">
                    <label>학습 자료 (새 파일 추가)</label>                   
                    <input type="file" name="pdfFiles" multiple>
                    
                    <div class="current-file">
                        <p>현재 자료 목록:</p>
                        <c:choose>
                            <c:when test="${not empty pdfList}">
                                <c:forEach var="pdf" items="${pdfList}">
                                    <div class="pdf-item">
    									<span>${pdf.pdpdf}</span>
    
    									<button type="button" class="pdf-delete-btn" 
            								onclick="deletePdf(${pdf.pno}, ${lesson.lno})">삭제</button>
									</div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p>등록된 학습 자료가 없습니다.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>강의 분류</label>
                    <select name="lcate" required>
                        <option value="voca" ${lesson.lcate == 'voca' ? 'selected' : ''}>단어</option>
                        <option value="speaking" ${lesson.lcate == 'speaking' ? 'selected' : ''}>스피킹</option>
                        <option value="grammar" ${lesson.lcate == 'grammar' ? 'selected' : ''}>문법</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>강의 레벨</label>
                    <select name="llevel" required>
                        <option value="1" ${lesson.llevel == '1' ? 'selected' : ''}>Level 1</option>
                        <option value="2" ${lesson.llevel == '2' ? 'selected' : ''}>Level 2</option>
                        <option value="3" ${lesson.llevel == '3' ? 'selected' : ''}>Level 3</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">강의 정보 저장</button>
                <a href="${cp}/teacher/lessonDelete?lno=${lesson.lno}" class="btn btn-delete" onclick="return confirm('정말 삭제하시겠습니까?');">강의 삭제</a>
            </form>
        </div>

        <div class="section">
            <h2>주차 관리</h2>
            <c:forEach var="week" items="${weeksList}">
                <div class="week-item">
                    <span>${week.wname}</span>
                    <div class="week-item-actions">
                        <button class="btn btn-warning" onclick="toggleEditForm('week-edit-${week.wno}')">수정</button>
                        <a href="${pageContext.request.contextPath}/teacher/weekDelete?wno=${week.wno}&lno=${lesson.lno}" class="btn btn-danger" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                    </div>
                </div>
                <div id="week-edit-${week.wno}" class="week-edit-form">
                    <jsp:include page="_weekUpdateForm.jsp">
                        <jsp:param name="wno" value="${week.wno}" />
                        <jsp:param name="wname" value="${week.wname}" />
                        <jsp:param name="lno" value="${lesson.lno}" />
                    </jsp:include>
                </div>
            </c:forEach>
        </div>
    </div>
    
    <jsp:include page="/WEB-INF/views/include/footer.jsp" />

    <script>
        // 수정 폼 토글 함수
        function toggleEditForm(formId) {
            document.querySelectorAll('.week-edit-form').forEach(form => {
                if (form.id !== formId) form.style.display = 'none';
            });
            const form = document.getElementById(formId);
            form.style.display = (form.style.display === 'block') ? 'none' : 'block';
        }
        
        function deletePdf(pno, lno) {
            if (confirm('이 자료를 삭제하시겠습니까?')) {
                // 1. 동적으로 form 요소를 생성
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${cp}/teacher/pdfDelete';
                
                // 2. pno 값을 가진 input 생성
                const pnoInput = document.createElement('input');
                pnoInput.type = 'hidden';
                pnoInput.name = 'pno';
                pnoInput.value = pno;
                form.appendChild(pnoInput);
                
                // 3. lno 값을 가진 input 생성
                const lnoInput = document.createElement('input');
                lnoInput.type = 'hidden';
                lnoInput.name = 'lno';
                lnoInput.value = lno;
                form.appendChild(lnoInput);
                
                // 4. form을 body에 추가하고 즉시 submit
                document.body.appendChild(form);
                form.submit();
            }
        }

        // 팀원의 업로드 스크립트 함수 (그대로 사용)
        function bindUploadForm(formId, fileInputId, dropId, previewId, barId, percentId, msgId) {
            const form = document.getElementById(formId);
            const fileInput = document.getElementById(fileInputId);
            const drop = document.getElementById(dropId);
            const preview = document.getElementById(previewId);
            const bar = document.getElementById(barId);
            const percent = document.getElementById(percentId);
            const msg = document.getElementById(msgId);

            if (!form || !fileInput || !drop) return; // 요소가 없으면 실행 중단

            fileInput.addEventListener('change', () => {
                const f = fileInput.files[0];
                if (!f) return;
                const url = URL.createObjectURL(f);
                if(preview) {
                    preview.src = url;
                    preview.style.display = 'block';
                }
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
                    if (xhr.status === 200 && xhr.responseText.startsWith('OK:')) {
                        msg.textContent = '교체 성공!';
                        setTimeout(() => window.location.reload(), 1000);
                    } else {
                        msg.textContent = '실패: ' + xhr.responseText;
                    }
                };
                xhr.onerror = () => { msg.textContent = '업로드 중 오류가 발생했습니다.'; };
                xhr.send(fd);
            });
        }

        // 페이지가 완전히 로드된 후, 각 수정 폼에 대해 업로드 스크립트를 적용
        document.addEventListener("DOMContentLoaded", function() {
            <c:forEach var="week" items="${weeksList}">
                bindUploadForm(
                    'formUpdate_${week.wno}',
                    'file_${week.wno}',
                    'drop_${week.wno}',
                    'preview_${week.wno}',
                    'bar_${week.wno}',
                    'percent_${week.wno}',
                    'msg_${week.wno}'
                );
            </c:forEach>
        });
    </script>
</body>
</html>

