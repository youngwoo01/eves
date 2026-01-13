package com.daegu.eves.teacher;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class TeacherDao {

	
    @Autowired
    private JdbcTemplate jdbcTemplate;
       
    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;
       
    // 로그인 기능
    public TeacherVo login(TeacherVo vo) {
       String sql = "select * from teacher where tid = ?";
        
        try {
           RowMapper<TeacherVo> rowMapper = BeanPropertyRowMapper.newInstance(TeacherVo.class);
            TeacherVo teacher = jdbcTemplate.queryForObject(sql, rowMapper, vo.getTid());
            
            // 암호화된 비밀번호 조회
            if(!bCryptPasswordEncoder.matches(vo.getTpw(), teacher.getTpw())) {
                return null; // 로그인 실패
            }else {
               return teacher; // 로그인 성공
            }
            
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
     }     
    
    public TeacherVo teacherInfo(String tid) {
    	String sql="select * from teacher where tid=?";
    	RowMapper<TeacherVo> rowMapper=
    			BeanPropertyRowMapper.newInstance(TeacherVo.class);
    	TeacherVo result=jdbcTemplate.queryForObject(sql,rowMapper,tid);

    	return result;
    }
    
    // 아이디 중복 체크
    public boolean existTid(String tid) {
        String sql = "SELECT COUNT(*) FROM teacher WHERE tid = ?";
        int count = jdbcTemplate.queryForObject(sql, Integer.class, tid);
        return count > 0;
    }

    // 강사 등록
    public int insertTeacher(TeacherVo vo) {
        String sql = "INSERT INTO teacher (tid, tpw, tphoto, tname, temail, tdate, tdescription, tchk) " +
                     "VALUES (?, ?, ?, ?, ?, NOW(), ?, ?)";

        return jdbcTemplate.update(sql,
                vo.getTid(),
                vo.getTpw(),
                vo.getTphoto(),
                vo.getTname(),
                vo.getTemail(),
                vo.getTdescription(),
                vo.getTchk());
    }
    
    // 강사 정보 수정페이지
    public TeacherVo findByTid(String tid) {
  	  RowMapper<TeacherVo> rowMapper = 
                BeanPropertyRowMapper.newInstance(TeacherVo.class);
      String sql = "SELECT * FROM teacher WHERE tid = ?";
      List<TeacherVo> list = jdbcTemplate.query(sql, rowMapper, tid);
      return list.isEmpty() ? null : list.get(0);
    }
    
    //강사 정보 수정
    public int updateTeacherInfo(TeacherVo vo) {
        String sql = "UPDATE teacher SET tpw = ?, tname = ?, temail = ?, tphoto = ?, tdescription = ? WHERE tid = ?";
        return jdbcTemplate.update(sql,
                vo.getTpw(),
                vo.getTname(),
                vo.getTemail(),
                vo.getTphoto(),
                vo.getTdescription(),
                vo.getTid());
    }
    
    // 강사 탈퇴 했을때 날짜 카운트
    public int updateDeleteSchedule(String tid, LocalDateTime now, LocalDateTime due) {
        String sql = "UPDATE teacher SET delete_request_date=?, delete_due_date=? WHERE tid=?";
        return jdbcTemplate.update(sql, now, due, tid);
    }
    
    // 삭제 대상 강사 조회
    public List<String> findExpiredTeachers() {
        String sql = "SELECT tid FROM teacher WHERE delete_due_date <= NOW()";
        return jdbcTemplate.queryForList(sql, String.class);
    }
    
    // 강사 삭제기간 남은 일수
    public LocalDateTime findDeleteDueDate(String tid) {
        String sql = "SELECT delete_due_date FROM teacher WHERE tid=?";
        List<LocalDateTime> list = jdbcTemplate.query(
            sql,
            (rs, i) -> {
                var ts = rs.getTimestamp(1);
                return ts == null ? null : ts.toLocalDateTime();
            },
            tid
        );
        return list.isEmpty() ? null : list.get(0);
    }

    // 강사 삭제
    @Transactional // 하나라도 실패하면 롤백
    public void deleteRelatedData(String tid) {
        // 1. 강사 번호로 강의 번호 조회
        String getLessonSql = "SELECT lno FROM lesson WHERE tno = (SELECT tno FROM teacher WHERE tid = ?)";
        List<Integer> lessonList = jdbcTemplate.queryForList(getLessonSql, Integer.class, tid);

        for (Integer lno : lessonList) {
            // 1-1. 주차 삭제
            String delWeek = "DELETE FROM weeks WHERE lno = ?";
            jdbcTemplate.update(delWeek, lno);

            // 1-2. PDF 삭제
            String delPdf = "DELETE FROM pdf WHERE lno = ?";
            jdbcTemplate.update(delPdf, lno);

            // 1-3. bridge 삭제 (회원과 강의 연결 테이블)
            String delBridge = "DELETE FROM bridge WHERE lno = ?";
            jdbcTemplate.update(delBridge, lno);

            // 1-4. 강의 삭제
            String delLesson = "DELETE FROM lesson WHERE lno = ?";
            jdbcTemplate.update(delLesson, lno);
        }

        // 2. 강사 삭제
        String delTeacher = "DELETE FROM teacher WHERE tid = ?";
        jdbcTemplate.update(delTeacher, tid);
    }
    
    
    //admin의 강사정보 불러오기 
    public List<TeacherVo> getTeacherList(){

        String sql = "select * from teacher"; 
        
        RowMapper<TeacherVo> rowMapper = 
                BeanPropertyRowMapper.newInstance(TeacherVo.class);
        List<TeacherVo>  reuslt= jdbcTemplate.query(sql, rowMapper);
        return reuslt;
        
    }
    
    // 강사 승인 상태 업데이트
    public void updateApproval(int tno, int status) {
        String sql = "UPDATE teacher SET tchk = ? WHERE tno = ?";
        jdbcTemplate.update(sql, status, tno);
    }
    
//    // RowMapper
//    private RowMapper<TeacherVo> teacherMapper = new RowMapper<TeacherVo>() {
//        @Override
//        public TeacherVo mapRow(ResultSet rs, int rowNum) throws SQLException {
//            TeacherVo t = new TeacherVo();
//            t.setTno(rs.getInt("tno"));
//            t.setTid(rs.getString("tid"));
//            t.setTpw(rs.getString("tpw"));
//            t.setTphoto(rs.getString("tphoto"));
//            t.setTname(rs.getString("tname"));
//            t.setTchk(rs.getInt("tchk"));
//            return t;
//        }
//    };
//

//
//    public int insertTeacher(TeacherVo teacher) {
//        String sql = "INSERT INTO teacher(tid, tpw, tphoto, tname, tchk) VALUES(?,?,?,?,?)";
//        return jdbcTemplate.update(sql, 
//            teacher.getTid(), 
//            teacher.getTpw(), 
//            teacher.getTphoto(), 
//            teacher.getTname(), 
//            teacher.getTchk());
//    }
}
