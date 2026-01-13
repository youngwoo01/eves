<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 강사가입</title>
  <style>
    .join-container {
      max-width: 400px;
      margin: 50px auto;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 8px;
      background: #fff;
    }
    .join-container h2 { text-align: center; margin-bottom: 20px; }
    .join-container label { display:block; margin:10px 0 5px; }
    .join-container input {
      width: 100%; padding: 10px; border:1px solid #ccc; border-radius:4px;
    }
    .join-container button.submit-btn {
      margin-top: 20px;
      width: 100%; padding: 12px;
      background: #0b63ce; color:#fff; border:none; border-radius:6px;
      font-weight: bold; cursor: pointer;
    }
    .join-container button.submit-btn:hover { background: #094fa6; }
    .id-row {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .id-row input {
      flex: 1; /* 입력창은 늘어나고 */
    }
     .id-row button {
      padding: 6px 10px;
      font-size: 12px;
      background: #666;
      color: #fff;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      width: auto;
    }
    .id-row button:hover {
      background: #444;
    }
    .id-row span {
      font-size: 12px;
    }
    
  </style>

  <link rel="stylesheet" href="/eves/resources/css/one.css" />
  
    <script>
  function checkTid(){
     
     let tid=document.frm.tid.value
     if (tid === "") {
           alert("아이디를 입력하세요");
           return;
       }
     location.href = "${pageContext.request.contextPath}/teacher/checkTid?tid=" + tid;
  }
  
  </script>
</head>
<body>
  <div class="site-wrap">

    <%@ include file="../include/header.jsp" %> 

    <main class="site-main">
      <div class="main-container">
         <div class="join-container">
    <h2>강사 회원가입</h2>
    <form method="post" action="${pageContext.request.contextPath}/teacher/JoinOk" name="frm"  enctype="multipart/form-data">

      <label for="tid">아이디</label>
   <div class="id-row">
     <input type="text" id="tid" name="tid" value="${tidValue}" required />
      <button type="button" onclick="checkTid()">중복체크</button>
     <span id="tidResult">${msg}</span>
   </div>


      <label for="tpw">비밀번호</label>
      <input type="password" id="tpw" name="tpw" required />

      <label for="tname">이름</label>
      <input type="text" id="tname" name="tname" required />

      <label for="temail">이메일</label>
      <input type="email" id="temail" name="temail" required />

	  <label for="tdescription">경력설명</label>
	  <textarea id="tdescription" name="tdescription" rows="5" maxlength="500"
	    style="resize:none; width:100%; box-sizing:border-box;"
	  placeholder="간단히 경력/전문분야를 적어주세요.">${param.tdescription}</textarea>

      
      <label for="tphoto">프로필 사진</label>
      <input type="file" id="file" name="file" accept="image/*" placeholder="선택사항" />

      <button type="submit" class="submit-b	tn">가입하기</button>
    </form>
  </div>
      </div>
    </main>

    <%@ include file="../include/footer.jsp" %> 

  </div>
</body>
</html>