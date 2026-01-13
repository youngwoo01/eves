<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>새로운 강의 등록</title>
    <link rel="stylesheet" href="/eves/resources/css/one.css" />
    <style>
        .container {
            width: 80%;
            margin: 50px auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
        .form-group input[type="text"],
        .form-group input[type="file"],
        .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .submit-btn {
            background-color: #007bff;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
        }
        .submit-btn:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>

    <%@ include file="../include/header.jsp" %> 

    <div class="container">
        <h2>새로운 강의 등록 📝</h2>
        <hr><br>
        
        <form action="${pageContext.request.contextPath}/teacher/lessonAddOk" method="post" enctype="multipart/form-data">
            
            <div class="form-group">
                <label for="lsum">썸네일 이미지</label>
                <input type="file" id="lsum" name="thumbnailFile" required>
            </div>
            
            <div class="form-group">
                <label for="pdfFiles">강의 자료</label>
                <input type="file" id="pdfFiles" name="pdfFiles" multiple>
            </div>
            
            <div class="form-group">
                <label for="lname">강의명</label>
                <input type="text" id="lname" name="lname" placeholder="강의 제목을 입력하세요" required>
            </div>
            
            <div class="form-group">
                <label for="lcate">강의 분류</label>
                <select id="lcate" name="lcate" required>
                    <option value="">분류 선택</option>
                    <option value="voca">단어</option>
                    <option value="speaking">대화</option>
                    <option value="grammar">문법</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="llevel">강의 레벨</label>
                <select id="llevel" name="llevel" required>
                    <option value="">레벨 선택</option>
                    <option value="1">Level 1</option>
                    <option value="2">Level 2</option>
                    <option value="3">Level 3</option>
                </select>
            </div>
            
            <button type="submit" class="submit-btn">강의 등록하기</button>
            
        </form>
    </div>

    <%@ include file="../include/footer.jsp" %>

</body>
</html>