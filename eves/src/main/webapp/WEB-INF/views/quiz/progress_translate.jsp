<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>번역퀴즈 진행률</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body{font-family:system-ui, sans-serif; margin:24px; background:#fafafa;}
    .wrap{max-width:960px; margin:0 auto;}
    .row{margin:24px 0;}
    .card{padding:16px; border:1px solid #eee; border-radius:12px; background:#fff; box-shadow:0 2px 6px rgba(0,0,0,.06);}
    h1{margin:0; font-size:26px;}
    h2{margin:0 0 8px;}
    .hint{color:#666; font-size:13px;}
    canvas{width:100% !important; height:360px !important;}
    .top{display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap;}
    .chips{display:flex; gap:8px; flex-wrap:wrap;}
    .chip a{display:inline-block; padding:6px 10px; border-radius:999px; background:#f4f4f5; text-decoration:none; color:#111;}
    .chip.active a{background:#111; color:#fff;}
    .actions{display:flex; gap:8px; align-items:center;}
    .btn{padding:8px 12px; border:1px solid #ddd; border-radius:10px; background:#fff; cursor:pointer; text-decoration:none; color:#111; font-weight:500;}
    .btn:hover{background:#f6f6f6;}
    .btn.primary{background:#111; color:#fff; border-color:#111;}
    .btn.secondary{background:#007bff; color:#fff; border-color:#007bff;}
  </style>
</head>
<body>
<div class="wrap">
  <div class="row top">
    <h1>번역퀴즈 진행률</h1>

    <!-- ✅ 날짜 선택 chips -->
    <div class="chips">
      <div class="chip ${rangeDays==7  ? 'active':''}"><a href="${cp}/quiz-tr/progress?days=7">7일</a></div>
      <div class="chip ${rangeDays==14 ? 'active':''}"><a href="${cp}/quiz-tr/progress?days=14">14일</a></div>
      <div class="chip ${rangeDays==30 ? 'active':''}"><a href="${cp}/quiz-tr/progress?days=30">30일</a></div>
    </div>

    <!-- ✅ 퀴즈 종류 토글 -->
    <div class="chips">
      <div class="chip"><a href="${cp}/quiz/progress">일반 퀴즈</a></div>
      <div class="chip active"><a href="${cp}/quiz-tr/progress">번역 퀴즈</a></div>
    </div>

    <div class="actions">
      <button type="button" class="btn" onclick="history.back()">← 뒤로가기</button>
      <a class="btn primary" href="${cp}/main">home</a>
      <a class="btn primary" href="${cp}/quiz-tr/start">번역 퀴즈로</a>
    </div>
  </div>

  <!-- 평균 점수: 선그래프 -->
  <div class="row card">
    <h2>하루별 평균 점수</h2>
    <p class="hint">score의 일별 평균(정수 반올림)을 선으로 표시합니다.</p>
    <canvas id="chartScore"></canvas>
  </div>

  <!-- 맞춘 개수: 막대그래프 -->
  <div class="row card">
    <h2>하루별 맞춘 개수</h2>
    <p class="hint">correct=1의 일별 합계를 막대로 표시합니다.</p>
    <canvas id="chartCorrect"></canvas>
  </div>
</div>

<script>
  // 서버에서 JSTL 데이터를 자바스크립트 배열로 변환
  const labels = [
    <c:forEach var="d" items="${labels}" varStatus="s">"${d}"<c:if test="${!s.last}">,</c:if></c:forEach>
  ];
  const avgScores = [
    <c:forEach var="n" items="${avgScores}" varStatus="s">${n==null ? 'null' : n}<c:if test="${!s.last}">,</c:if></c:forEach>
  ];
  const correctCounts = [
    <c:forEach var="n" items="${correctCounts}" varStatus="s">${n}<c:if test="${!s.last}">,</c:if></c:forEach>
  ];

  // 평균 점수 추이 (선그래프)
  new Chart(document.getElementById("chartScore"), {
    type: 'line',
    data: {
      labels: labels,
      datasets: [{
        label: '평균 점수',
        data: avgScores,
        borderColor: '#2b6ded',
        backgroundColor: '#2b6ded33',
        tension: 0.25,
        pointRadius: 4,
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: { beginAtZero: true, max: 100, title: { display: true, text: "점수" } },
        x: { title: { display: true, text: "날짜" } }
      },
      plugins: { legend: { display: false } }
    }
  });

  // 정답 수 추이 (막대그래프)
  new Chart(document.getElementById("chartCorrect"), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: '정답 개수',
        data: correctCounts,
        backgroundColor: '#34d399cc',
        borderColor: '#10b981',
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: { beginAtZero: true, title: { display: true, text: "정답 수" } },
        x: { title: { display: true, text: "날짜" } }
      },
      plugins: { legend: { display: false } }
    }
  });
</script>
</body>
</html>
