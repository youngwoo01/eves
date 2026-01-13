<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>아동용 학습사이트 - 회원가입</title>
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
  function checkUid(){
     
     let uid=document.frm.id.value    
     location.href = "${pageContext.request.contextPath}/user/checkUid?uid=" + uid;
//    alert(uid)
     
  }
  
  </script>
</head>
<body>
  <div class="site-wrap">

    <%@ include file="../include/header.jsp" %> 

    <main class="site-main">
      <div class="main-container">
         <div class="join-container">
      <h2>회원가입</h2>
      <form method="post" action="${pageContext.request.contextPath}/user/JoinOk" name="frm">

      
        <label for="id">아이디</label>
        <div class="id-row">
        <input type="text" id="id" name="id" value="${uidValue}" required />
        <button type="button" name="chkbtn" onclick="checkUid()">중복체크</button>
        <span id="uidResult">${msg}</span>
        </div>
              
      	<label for="name">이름</label>
        <input type="text" id="name" name="name" required />

        <label for="pw">비밀번호</label>
        <input type="password" id="pw" name="pw" required />

        <label for="email">이메일</label>
        <input type="email" id="email" name="email" required />

        
        <button type="submit" class="submit-btn">가입하기</button>
      </form>
    </div>
      </div>
    </main>

    <%@ include file="../include/footer.jsp" %> 

  </div>
</body>
</html>
