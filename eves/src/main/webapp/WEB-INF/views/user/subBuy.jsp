<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
  :root {
    --main-color: #4f46e5;   /* 진한 보라 (메인 색상) */
    --sub-color: #eef2ff;   /* 연한 보라 배경 */
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
    max-width: 600px;
  }

  .join-container {
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.08);
    padding: 40px 32px;
    animation: fadein 0.5s ease;
  }

  @keyframes fadein {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }

  h2 {
    font-size: 1.8rem;
    font-weight: 700;
    margin-bottom: 24px;
    text-align: center;
    color: var(--main-color);
  }

  form {
    display: grid;
    gap: 18px;
  }

  label {
    font-weight: 600;
    margin-bottom: 6px;
    display: block;
  }

  select,
  input[type="date"],
  input[type="text"] {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    font-size: 0.95rem;
    transition: border 0.2s, box-shadow 0.2s;
  }

  select:focus,
  input:focus {
    outline: none;
    border-color: var(--main-color);
    box-shadow: 0 0 0 3px rgba(79,70,229,0.1);
  }

  input[name="sprice"] {
    background-color: #f9fafb;
    color: #555;
    font-weight: 600;
  }

  button[type="submit"] {
    margin-top: 10px;
    background: var(--main-color);
    color: #fff;
    font-size: 1rem;
    font-weight: 600;
    padding: 12px 0;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    transition: background 0.2s ease, transform 0.1s ease;
  }

  button[type="submit"]:hover {
    background: #4338ca;
    transform: translateY(-2px);
  }

  button[type="submit"]:active {
    transform: translateY(0);
  }

</style>
 <link rel="stylesheet" href="/eves/resources/css/one.css" />
</head>
<div class="site-wrap">

    <%@ include file="../include/header.jsp" %> 

    <main class="site-main">
      <div class="main-container">
         <div class="join-container">
<h2>구독 결제</h2>

  <form action="<c:url value='/user/subBuy'/>" method="post">
  <!-- 구독기간: selectedMonth 자동 선택 -->
  <label>구독기간</label>
  <select name="planMonth" disabled>
    <option value="1"  ${selectedMonth==1 ? 'selected' : ''}>1개월</option>
    <option value="6"  ${selectedMonth==6 ? 'selected' : ''}>6개월</option>
    <option value="12" ${selectedMonth==12? 'selected' : ''}>12개월</option>
  </select>
  <br/>
  
  <!-- 실제 서버로 보내는 값 -->
  <input type="hidden" name="planMonth" value="${selectedMonth}" />

  <!-- 결제일: 기본 오늘 -->
  <label>결제일</label>
  <input type="date" name="payDate" value="${payDate}"/>
  <br/>

  <label>결제금액</label>
  <input type="text" name="sprice" value="${price}" readonly/>
  <br/>


  <!-- 결제수단 -->
  <label>결제수단</label>
  <select name="payMethod">
    <option value="CARD">카드</option>
    <option value="CASH">계좌이체</option>
  </select>
  <br/><br/>

  <button type="submit">결제</button>
</form>
    </div>
      </div>
    </main>

    <%@ include file="../include/footer.jsp" %> 

  </div>
</body>
</html>