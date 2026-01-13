<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .search-wrap {
    display: flex;
    justify-content: flex-end; /* ✅ 오른쪽 정렬 */
    margin: 20px auto;
    max-width: 1100px; /* 필요 시 사이트 폭 맞춤 */
  }

  .search-bar {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 16px;
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 12px;
    width: 420px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  }

  .search-bar select,
  .search-bar input[type="text"] {
    padding: 10px 12px;
    border: 1px solid #ccc;
    border-radius: 8px;
    font-size: 14px;
  }

  .search-bar select {
    width: 110px;
    background: #fafafa;
  }

  .search-bar input[type="text"] {
    flex: 1;
  }

  .search-bar button {
    padding: 10px 16px;
    border: none;
    background: #2b6ded;
    color: #fff;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: 0.2s;
  }

  .search-bar button:hover {
    background: #1f57b0;
  }
  .search-bar button:active {
    transform: scale(0.97);
  }
</style>

<nav>
  <div class="search-wrap">
    <form action="<c:url value='/main/searchOk'/>" method="get" class="search-bar">
      <select name="type">
        <option value="lname" ${type == 'lname' ? 'selected' : ''}>강의명</option>
        <option value="tname" ${type == 'tname' ? 'selected' : ''}>강사명</option>
      </select>

      <input type="text" name="keyword" value="${keyword}" placeholder="검색어를 입력하세요" />

      <button type="submit">검색</button>
    </form>
  </div>
</nav>
