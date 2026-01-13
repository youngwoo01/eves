<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<c:if test="${subscribeMsg}">
<script>
	alert("구독권 결제가 완료되었습니다!");
</script>
</c:if>
<c:if test="${subscribeMsg2}">
<script>
   alert("구독권 결제 이후 이용가능한 서비스입니다.");
</script>
</c:if>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
  :root {
    --main-color: #4f46e5;     
    --sub-color: #eef2ff;      
    --text-color: #333;
    --border-color: #ddd;
  }

  body {
    font-family: 'Pretendard', 'Noto Sans KR', sans-serif;
    background-color: var(--sub-color);
    color: var(--text-color);
    margin: 0;
    padding: 0;
  }

  .site-main {
    display: flex;
    justify-content: center;
    align-items: flex-start;
    min-height: 100vh;
    padding: 60px 20px;
  }

  .main-container {
    width: 100%;
    max-width: 700px;
  }

  .join-container {
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.08);
    padding: 40px 32px;
    text-align: center;
    animation: fadein 0.5s ease;
  }

  @keyframes fadein {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }

  h2 {
    font-size: 1.8rem;
    font-weight: 700;
    margin-bottom: 20px;
    color: var(--main-color);
  }

  hr {
    margin: 20px 0;
    border: 0;
    border-top: 1px solid var(--border-color);
  }

  /* 상태 텍스트 */
  c\:choose, span.status {
    display: inline-block;
    padding: 6px 14px;
    font-size: 0.95rem;
    font-weight: 600;
    border-radius: 20px;
    background: #f3f4f6;
    color: #555;
  }

  /* 버튼 공통 */
  form {
    display: inline-block;
    margin: 10px;
  }

  button {
    background: var(--main-color);
    color: #fff;
    font-size: 1rem;
    font-weight: 600;
    padding: 14px 32px;
    border: none;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 0 4px 10px rgba(79,70,229,0.2);
  }

  button:hover {
    background: #4338ca;
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(79,70,229,0.3);
  }

  button:active {
    transform: translateY(0);
  }

  /* 구독 상태 강조 */
  .status-box {
    font-weight: 600;
    margin-bottom: 12px;
    color: var(--main-color);
  }
</style>

 <link rel="stylesheet" href="/eves/resources/css/one.css" />
</head>
<div class="site-wrap">

    <%@ include file="../include/header.jsp" %> 

    <main class="site-main">
      <div class="main-container">
         <div class="join-container">
<h2>구독권 선택</h2>

<!-- 상태표시: 질문에 준 choose 유지 -->
<c:choose>
  <c:when test="${user.uchk == 1 or user.uchk == '1'}">
    구독중 (종료일: ${user.send})
  </c:when>
  <c:otherwise>
  </c:otherwise>
</c:choose>
<hr/>

<!-- 세 개 버튼: GET /user/subBuy?planMonth=... -->
<form action="<c:url value='/user/subBuy'/>" method="get">
  <input type="hidden" name="planMonth" value="1"/>
  <button type="submit">1개월(₩9,900)</button>
</form>

<form action="<c:url value='/user/subBuy'/>" method="get">
  <input type="hidden" name="planMonth" value="6"/>
  <button type="submit">6개월(₩46,500)</button>
</form>

<form action="<c:url value='/user/subBuy'/>" method="get">
  <input type="hidden" name="planMonth" value="12"/>
  <button type="submit">12개월(₩89,500)</button>
</form>
    </div>
      </div>
    </main>

    <%@ include file="../include/footer.jsp" %> 

  </div>
</body>
</html>